import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  List<String> subjects = [];
  List<String> fixed = [];
  String tomorrowDay = "";

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

  @override
  void initState() {
    super.initState();
    generateChecklist();
  }

  String getTomorrowDay() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return days[tomorrow.weekday - 1];
  }

  Future<void> generateChecklist() async {
    final timetableRaw = await AppStorage.getTimeTable();
    final fixedItems = await AppStorage.getFixedItems();
    final profile = await AppStorage.getChildProfile();

    if (profile == null) return;

    List<String> schoolDays =
    List<String>.from(profile['schoolDays'] ?? [])
        .map((e) => normalizeDay(e))
        .toList();

    const daysOrder = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    DateTime now = DateTime.now();

    /// same rule as dashboard
    if (now.hour >= 12) {
      now = now.add(const Duration(days: 1));
    }

    String? selectedDay;
    List<String> subjectsList = [];

    for (int i = 0; i < 7; i++) {
      final checkDay = daysOrder[(now.weekday - 1 + i) % 7];
      final normalizedDay = normalizeDay(checkDay);

      if (!schoolDays.contains(normalizedDay)) continue;

      bool hasSubjects =
          timetableRaw != null &&
              timetableRaw.containsKey(normalizedDay) &&
              (timetableRaw[normalizedDay] as List).isNotEmpty;

      if (!hasSubjects) continue;

      selectedDay = normalizedDay;
      subjectsList = List<String>.from(timetableRaw[normalizedDay]);
      break;
    }

    setState(() {
      tomorrowDay = selectedDay ?? "No Bag";
      subjects = subjectsList;
      fixed = fixedItems;
    });
  }

  void continueToHome() {
    context.go('/home');
  }

  /// 🔥 Premium Item Card
  Widget buildItem(String item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔙 Back + Progress
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/reminder');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.4),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔵 Title
                const Text(
                  "Tomorrow’s Bag",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "For $tomorrowDay",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔵 Checklist
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: (subjects.isEmpty && fixed.isEmpty)
                        ? const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                        : ListView(
                      children: [

                        /// 📘 Subjects
                        if (subjects.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Subjects",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ...subjects.map(buildItem),
                          const SizedBox(height: 10),
                        ],

                        /// 🎒 Fixed Items
                        if (fixed.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Fixed Items",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          ...fixed.map(buildItem),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔵 CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: continueToHome,
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "Looks Good",
                      style: TextStyle(fontSize: 16),
                    ),
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