import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/local_db/app_storage.dart';
import '../../../core/utils/notification_service.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int streak = 0;
  List<String> tomorrowItems = [];
  String reminderTime = "Not Set";

  String currentBagDay = ""; // ✅ IMPORTANT

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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await loadStreak();
    await loadTomorrowItems();
    await loadReminderTime();
    await _rescheduleReminder();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadTomorrowItems();
    refreshDashboard();
  }

  // ---------- REMINDER ----------

  Future<void> editReminder() async {
    final saved = await AppStorage.getReminderTime();

    TimeOfDay initialTime = const TimeOfDay(hour: 20, minute: 0);

    if (saved != null) {
      final parts = saved.split(":");
      initialTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final newTime = "${picked.hour}:${picked.minute}";

      await AppStorage.saveReminderTime(newTime);
      await NotificationService().scheduleDailyReminder(newTime);

      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        reminderTime = TimeOfDay.fromDateTime(dt).format(context);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reminder updated")),
      );
    }
  }

  Future<void> _rescheduleReminder() async {
    final savedTime = await AppStorage.getReminderTime();
    if (savedTime != null) {
      await NotificationService().scheduleDailyReminder(savedTime);
    }
  }

  // ---------- LOAD DATA ----------

  Future<void> loadStreak() async {
    final data = await AppStorage.getStreak();
    setState(() {
      streak = data?['count'] ?? 0;
    });
  }

  Future<void> loadReminderTime() async {
    final saved = await AppStorage.getReminderTime();

    if (saved != null) {
      final parts = saved.split(":");

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, hour, minute);

      setState(() {
        reminderTime = TimeOfDay.fromDateTime(dt).format(context);
      });
    }
  }

  // ---------- 🔥 CORE LOGIC ----------
  Future<void> loadTomorrowItems() async {
    final timetableRaw = await AppStorage.getTimeTable();
    final fixed = await AppStorage.getFixedItems();
    final profile = await AppStorage.getChildProfile();

    if (profile == null) return;

    List<String> schoolDays =
    List<String>.from(profile['schoolDays'] ?? [])
        .map((e) => normalizeDay(e))
        .toList();

    const daysOrder = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    DateTime now = DateTime.now();

    if (now.hour >= 12) {
      now = now.add(const Duration(days: 1));
    }

    String? selectedDay;
    List<String> subjects = [];

    for (int i = 0; i < 7; i++) {
      final checkDay = daysOrder[(now.weekday - 1 + i) % 7];
      final normalizedDay = normalizeDay(checkDay);

      /// ✅ MUST be school day
      if (!schoolDays.contains(normalizedDay)) continue;

      /// ✅ MUST have timetable subjects
      bool hasSubjects =
          timetableRaw != null &&
              timetableRaw.containsKey(normalizedDay) &&
              (timetableRaw[normalizedDay] as List).isNotEmpty;

      /// 🔥 ONLY accept day if it has subjects
      if (!hasSubjects) continue;

      selectedDay = normalizedDay;
      subjects = List<String>.from(timetableRaw[normalizedDay]);

      break;
    }

    /// ❌ No valid school day found
    if (selectedDay == null) {
      setState(() {
        tomorrowItems = [];
        currentBagDay = "No Bag";
      });
      return;
    }

    /// ✅ VALID DAY FOUND
    setState(() {
      tomorrowItems = [...subjects, ...fixed];
      currentBagDay = selectedDay!;
    });
  }

  Future<void> refreshDashboard() async {
    await loadTomorrowItems();
    await loadStreak();
    await loadReminderTime();
  }

  // ---------- BOTTOM SHEET ----------
  void showFullList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.only(bottom: bottomPadding + 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "$currentBagDay’s Bag",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: tomorrowItems.isEmpty
                    ? const Center(child: Text("No bag packing 🎉"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tomorrowItems.length,
                  itemBuilder: (_, i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(tomorrowItems[i])),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPreviewItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget actionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final previewItems = tomorrowItems.take(3).toList();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dashboard",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// BAG PREVIEW
                GestureDetector(
                  onTap: showFullList,
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$currentBagDay’s Bag",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),

                        if (tomorrowItems.isEmpty)
                          const Text("No bag packing 🎉")
                        else
                          ...previewItems.map(buildPreviewItem),

                        if (tomorrowItems.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "+${tomorrowItems.length - 3} more items",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// STREAK + REMINDER
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        child: Column(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange),
                            const SizedBox(height: 6),
                            Text("$streak Days",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Streak"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: editReminder,
                        child: GlassContainer(
                          child: Column(
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(height: 6),
                              Text(reminderTime,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text("Reminder", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ACTIONS
                Expanded(
                  child: GlassContainer(
                    child: ListView(
                      children: [
                        actionTile(
                          title: "Verify Today’s Bag",
                          icon: Icons.verified,
                          onTap: () => context.push('/parent-verify'),
                        ),
                        actionTile(
                          title: "Edit Timetable",
                          icon: Icons.calendar_today,
                          onTap: () async {
                            await context.push('/edit-timetable');
                            await refreshDashboard();
                          },
                        ),
                        actionTile(
                          title: "Fixed Items",
                          icon: Icons.inventory_2,
                          onTap: () async {
                            await context.push('/edit-fixed-items');
                            await refreshDashboard();
                          },
                        ),
                        actionTile(
                          title: "Child Profile",
                          icon: Icons.person,
                          onTap: () async {
                            await context.push('/edit-profile');
                            await refreshDashboard();
                          },
                        ),
                        actionTile(
                          title: "Change PIN",
                          icon: Icons.lock,
                          onTap: () => context.push('/change-pin'),
                        ),
                      ],
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