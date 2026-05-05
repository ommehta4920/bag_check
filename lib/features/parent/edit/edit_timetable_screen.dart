import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';
import '../../../data/constants/timetable_templates.dart';

class EditTimetableScreen extends StatefulWidget {
  const EditTimetableScreen({super.key});

  @override
  State<EditTimetableScreen> createState() =>
      _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {

  Map<String, List<String>> timetable = {};
  List<String> days = [];
  String selectedDay = "";

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  // ---------- DAY NORMALIZER ----------
  String normalizeDay(String day) {
    switch (day.toLowerCase()) {
      case 'mon':
      case 'monday':
        return 'Mon';
      case 'tue':
      case 'tuesday':
        return 'Tue';
      case 'wed':
      case 'wednesday':
        return 'Wed';
      case 'thu':
      case 'thursday':
        return 'Thu';
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

  // ---------- SORT DAYS ----------
  List<String> sortDays(List<String> input) {
    const order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    input = input.map((e) => normalizeDay(e)).toList();

    input.sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));

    return input;
  }

  // ---------- LOAD ----------
  Future<void> load() async {
    final profile = await AppStorage.getChildProfile();
    final data = await AppStorage.getTimeTable();

    if (profile != null) {
      final board =
      profile['board']?.toString().toUpperCase() == "CBSE"
          ? "CBSE"
          : "State";

      final studentClass = profile['class'].toString();

      days = sortDays(List<String>.from(profile['schoolDays'] ?? []));
      selectedDay = days.isNotEmpty ? days.first : "";

      /// Load existing timetable
      if (data != null) {
        timetable = Map<String, List<String>>.from(
          data.map(
                (key, value) => MapEntry(
              key.toString(),
              List<String>.from(value ?? []),
            ),
          ),
        );
      }

      /// Remove unselected days
      timetable.removeWhere((key, value) => !days.contains(key));

      /// Inject defaults
      final template =
      TimetableTemplates.templates[board]?[studentClass];

      for (var day in days) {
        if (!timetable.containsKey(day) || timetable[day]!.isEmpty) {
          timetable[day] = List<String>.from(template?[day] ?? []);
        }
      }

      /// 🔥 Suggestions
      suggestions = timetable.values
          .expand((e) => e)
          .toSet()
          .toList();
    }

    setState(() {});
  }

  // ---------- ADD SUBJECT ----------
  void addSubject() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Text(
                  "Add Subject",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "e.g. Mathematics",
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
                  spacing: 10,
                  runSpacing: 10,
                  children: suggestions
                      .where((s) =>
                  !(timetable[selectedDay] ?? []).contains(s))
                      .map((s) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          timetable[selectedDay] ??= [];
                          timetable[selectedDay]!.add(s);
                        });
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
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final value = controller.text.trim();
                          if (value.isEmpty) return;

                          setState(() {
                            timetable[selectedDay] ??= [];
                            if (!timetable[selectedDay]!.contains(value)) {
                              timetable[selectedDay]!.add(value);
                            }
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Add"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- DELETE ----------
  void deleteSubject(int index) {
    setState(() {
      timetable[selectedDay]!.removeAt(index);
    });
  }

  // ---------- SAVE ----------
  Future<void> save() async {
    const order = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final sorted = <String, List<String>>{};

    for (var day in order) {
      if (timetable.containsKey(day)) {
        sorted[day] = timetable[day]!;
      }
    }

    await AppStorage.saveTimeTable(sorted);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Timetable saved")),
    );

    context.pop();
  }

  // ---------- SUBJECT TILE ----------
  Widget buildSubject(String text, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          GestureDetector(
            onTap: () => deleteSubject(index),
            child: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ),
    );
  }

  // ---------- DAY SELECTOR ----------
  Widget buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: days.map((day) {
        final isSelected = day == selectedDay;

        return GestureDetector(
          onTap: () => setState(() => selectedDay = day),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.08),
            ),
            child: Text(
              day[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final subjects = timetable[selectedDay] ?? [];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_ios_new),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Edit Timetable",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                buildDaySelector(),

                const SizedBox(height: 20),

                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: subjects.isEmpty
                        ? const Center(child: Text("No subjects added"))
                        : ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (_, i) =>
                          buildSubject(subjects[i], i),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addSubject,
                    child: const Text("Add Subject"),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: save,
                    child: const Text("Save Timetable"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}