import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';
import '../../../data/constants/timetable_templates.dart';

const Map<String, String> dayMap = {
  "Monday": "Mon",
  "Tuesday": "Tue",
  "Wednesday": "Wed",
  "Thursday": "Thu",
  "Friday": "Fri",
  "Saturday": "Sat",
  "Sunday": "Sun",

  // if already short, keep same
  "Mon": "Mon",
  "Tue": "Tue",
  "Wed": "Wed",
  "Thu": "Thu",
  "Fri": "Fri",
  "Sat": "Sat",
};

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {


  List<String> days = [];
  String selectedDay = "";

  Map<String, List<String>> timetable = {};

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final child = await AppStorage.getChildProfile();

    if (child != null) {
      final rawBoard = child['board'].toString().trim();
      final studentClass = child['class'].toString().trim();
      final schoolDaysRaw = List<String>.from(child['schoolDays']);

      final board =
      rawBoard.toUpperCase() == "CBSE" ? "CBSE" : "State";

      days = schoolDaysRaw.map((d) => normalizeDay(d)).toList();
      selectedDay = days.isNotEmpty ? days.first : "";

      /// 🔥 NEW: check if timetable already exists
      final hasSaved = await AppStorage.hasTimeTable();

      if (hasSaved) {
        /// ✅ Load saved timetable
        final stored = await AppStorage.getTimeTable();

        if (stored != null) {
          timetable = stored.map((key, value) {
            return MapEntry(
              key.toString(),
              List<String>.from(value),
            );
          });
        }
      } else {
        /// ✅ Load template
        final template =
        TimetableTemplates.templates[board]?[studentClass];

        timetable = {};

        for (var day in days) {
          timetable[day] = List<String>.from(
            template?[day] ?? [],
          );
        }
      }

      /// Suggestions
      suggestions = timetable.values
          .expand((e) => e)
          .toSet()
          .toList();

      setState(() {});
    }
  }

  String normalizeDay(String day) {
    switch (day.toLowerCase()) {
      case 'm':
      case 'mon':
      case 'monday':
        return 'Mon';
      case 't':
      case 'tue':
      case 'tuesday':
        return 'Tue';
      case 'w':
      case 'wed':
      case 'wednesday':
        return 'Wed';
      case 'thu':
      case 'thursday':
        return 'Thu';
      case 'f':
      case 'fri':
      case 'friday':
        return 'Fri';
      case 'sat':
      case 'saturday':
        return 'Sat';
      case 'sun':
      case 'sunday':
        return 'Sun';
      default:
        return day;
    }
  }

  void addSubject(String subject) {
    if (timetable[selectedDay]!.contains(subject)) return;

    setState(() {
      timetable[selectedDay]!.add(subject);
    });
  }

  void removeSubject(int index) {
    setState(() {
      timetable[selectedDay]!.removeAt(index);
    });
  }

  Future<void> saveTimetable() async {
    await AppStorage.saveTimeTable(timetable);
    context.go('/fixed-items');
  }

  /// 🔵 Dialog
  void openAddDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Text(
                      "Add Subject",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Enter subject",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Suggestions
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Suggestions",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: suggestions.map((s) {
                        return GestureDetector(
                          onTap: () {
                            addSubject(s);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: Text(s),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final text = controller.text.trim();
                              if (text.isNotEmpty) {
                                addSubject(text);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Add"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Day Selector
  Widget buildDaySelector() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        final isSelected = selectedDay == day;

        return GestureDetector(
          onTap: () => setState(() => selectedDay = day),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              )
                  : null,
              color: isSelected
                  ? null
                  : Colors.white.withValues(alpha: 0.7),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                day[0], // M, T, W...
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

// 🔵 Subjects Container (UPDATED)
  Widget buildSubjects() {
    final subjects = timetable[selectedDay] ?? [];

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: subjects.isEmpty
          ? const Center(child: Text("No subjects added"))
          : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subjects.length,
        itemBuilder: (_, index) {
          final subject = subjects[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, size: 20),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => removeSubject(index),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                const SizedBox(height: 20),

                /// 🔙 Back + Progress
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/child-profile'); // fallback
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.4,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.4),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Build Timetable",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                buildDaySelector(),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: buildSubjects(),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: openAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Subject"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                      elevation: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveTimetable,
                    child: const Text("Continue"),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}