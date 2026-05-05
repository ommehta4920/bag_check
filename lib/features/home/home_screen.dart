import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/local_db/app_storage.dart';
import '../../data/models/checklist_item.dart';

import '../child/widgets/child_header.dart';
import '../child/widgets/checklist_view.dart';
import '../child/widgets/completed_view.dart';
import '../child/widgets/complete_button.dart';
import '../child/widgets/progress_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChecklistItem> items = [];
  String activeDay = "";
  int streak = 0;
  bool isDayCompleted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await loadChecklist();
    await loadStreak();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadChecklist();
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

  // ---------- ACTIVE DAY (NO SKIPPING) ----------
  String getActiveDay() {
    final now = DateTime.now();

    int weekday = now.weekday;

    if (now.hour >= 12) {
      weekday += 1;
    }

    if (weekday > 7) weekday = 1;

    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  // ---------- LOAD ----------
  Future<void> loadChecklist() async {
    final profile = await AppStorage.getChildProfile();
    if (profile == null) return;

    final day = getActiveDay();

    List<String> schoolDays =
    List<String>.from(profile['schoolDays'] ?? [])
        .map((e) => normalizeDay(e))
        .toList();

    /// ❌ NOT A SCHOOL DAY → SHOW MESSAGE
    if (!schoolDays.contains(day)) {
      setState(() {
        activeDay = day;
        items = [];
        isDayCompleted = false;
      });
      return;
    }

    /// 🔁 LOAD SAVED CHECKLIST
    final saved = await AppStorage.getDailyChecklist(day);
    final completed = await AppStorage.isDayCompleted(day);

    if (saved != null) {
      setState(() {
        items = saved.map((e) => ChecklistItem.fromMap(e)).toList();
        activeDay = day;
        isDayCompleted = completed;
      });
      return;
    }

    final timetable = await AppStorage.getTimeTable();
    final fixed = await AppStorage.getFixedItems();

    List<String> subjects = [];

    if (timetable != null &&
        timetable.containsKey(day) &&
        (timetable[day] as List).isNotEmpty) {
      subjects = List<String>.from(timetable[day]);
    }

    final all = [...subjects, ...fixed];

    setState(() {
      activeDay = day;
      items = all.map((e) => ChecklistItem(name: e)).toList();
      isDayCompleted = false;
    });

    await saveChecklist();
  }

  Future<void> saveChecklist() async {
    final data = items.map((e) => e.toMap()).toList();
    await AppStorage.saveDailyChecklist(activeDay, data);
  }

  // ---------- ACTIONS ----------
  void toggleItem(int index) async {
    setState(() {
      items[index].isChecked = !items[index].isChecked;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });

    await saveChecklist();
  }

  Future<void> loadStreak() async {
    final data = await AppStorage.getStreak();
    if (data != null) {
      setState(() {
        streak = data['count'] ?? 0;
      });
    }
  }

  bool get isCompleted =>
      items.isNotEmpty && items.every((e) => e.isChecked);

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ChildHeader(
                  day: activeDay,
                  streak: streak,
                ),

                const SizedBox(height: 20),

                ProgressSection(
                  total: items.length,
                  completed: items.where((e) => e.isChecked).length,
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GlassContainer(
                    child: items.isEmpty
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.weekend,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No Bag Packing",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                        : isDayCompleted
                        ? CompletedView(streak: streak)
                        : ChecklistView(
                      items: items,
                      onTap: toggleItem,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (isCompleted && !isDayCompleted && items.isNotEmpty)
                  CompleteButton(
                    onPressed: () async {
                      final result =
                      await context.push('/parent-pin', extra: true);

                      if (result == true) {
                        context.go('/parent-dashboard');
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}