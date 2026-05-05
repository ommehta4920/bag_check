import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local_db/app_storage.dart';
import '../../data/models/checklist_item.dart';

class ParentVerificationScreen extends StatefulWidget {
  const ParentVerificationScreen({super.key});

  @override
  State<ParentVerificationScreen> createState() =>
      _ParentVerificationScreenState();
}

class _ParentVerificationScreenState
    extends State<ParentVerificationScreen> {

  List<ChecklistItem> items = [];
  bool isLoading = true;
  bool isAlreadyVerified = false;

  String activeDay = "";

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  // ---------- DAY LOGIC ----------

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

  Future<void> loadItems() async {
    final day = getActiveDay();
    activeDay = day;

    final saved = await AppStorage.getDailyChecklist(day);

    if (saved != null) {
      items = saved.map((e) => ChecklistItem.fromMap(e)).toList();
    }

    /// ✅ ONLY check after UI loads
    final isDone = await AppStorage.isDayCompleted(day);

    setState(() {
      isAlreadyVerified = isDone;
      isLoading = false;
    });
  }

  // ---------- ACTIONS ----------

  Future<void> onVerify() async {
    await _updateStreak();
    await AppStorage.markDayComplete(activeDay);

    final streak = await _getStreak();

    if (!mounted) return;

    context.go('/success', extra: streak);
  }

  Future<void> onRecheck() async {
    for (var item in items) {
      item.isChecked = false;
    }

    final data = items.map((e) => e.toMap()).toList();

    await AppStorage.saveDailyChecklist(activeDay, data);

    /// HARD RESET (important)
    await AppStorage.unmarkDayComplete(activeDay);

    if (!mounted) return;

    context.go('/parent-dashboard');
  }

  // ---------- STREAK ----------

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayStr = "${today.year}-${today.month}-${today.day}";
    final yesterdayStr =
        "${yesterday.year}-${yesterday.month}-${yesterday.day}";

    final streakData = await AppStorage.getStreak();

    int currentStreak = 0;
    String? lastDate;

    if (streakData != null) {
      currentStreak = streakData['count'] ?? 0;
      lastDate = streakData['last_date'];
    }

    if (lastDate == todayStr) return;

    if (lastDate == yesterdayStr) {
      currentStreak += 1;
    } else {
      currentStreak = 1; // reset
    }

    await AppStorage.saveStreak(currentStreak, todayStr);
  }

  Future<int> _getStreak() async {
    final data = await AppStorage.getStreak();
    return data?['count'] ?? 0;
  }

  // ---------- HELPERS ----------

  List<ChecklistItem> get packed =>
      items.where((e) => e.isChecked).toList();

  List<ChecklistItem> get remaining =>
      items.where((e) => !e.isChecked).toList();

  // ---------- ITEM UI ----------

  Widget buildItem(ChecklistItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: item.isChecked
            ? AppColors.success.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: item.isChecked
              ? AppColors.success.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.isChecked
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: item.isChecked
                ? AppColors.success
                : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 14,
                decoration:
                item.isChecked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget section(String title, List<ChecklistItem> data) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...data.map(buildItem),
        const SizedBox(height: 12),
      ],
    );
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Verify Bag",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Check packed and missing items",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 15),

                /// ALREADY VERIFIED MESSAGE
                if (isAlreadyVerified)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Already verified for today"),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),

                /// SUMMARY
                GlassContainer(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Progress"),
                      Text(
                        "${packed.length} / ${items.length}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// LIST
                Expanded(
                  child: GlassContainer(
                    child: items.isEmpty
                        ? const Center(
                      child: Text("No items found"),
                    )
                        : ListView(
                      children: [
                        section("✅ Packed Items", packed),
                        section("❗ Remaining Items", remaining),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: onRecheck,
                        child: const Text("Recheck"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: onVerify,
                        child: const Text("Approve"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}