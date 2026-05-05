import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';
import '../../../core/utils/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

  String get formattedTime {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    return DateFormat.jm().format(dt);
  }

  @override
  void initState() {
    super.initState();
    _loadReminder();
    _requestPermission();
  }

  // ---------- BATTERY SETTINGS ----------

  Future<void> openBatterySettings() async {
    const intent = AndroidIntent(
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
    );
    await intent.launch();
  }

  // Future<void> showBatteryDialog() async {
  //   if (!mounted) return;
  //
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text("Enable Reminder Notifications"),
  //       content: const Text(
  //         "To receive reminders on time, please allow:\n\n"
  //             "• Disable battery optimization\n"
  //             "• Enable auto start\n"
  //             "• Allow background activity\n\n"
  //             "This is required on some devices.",
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("Skip"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await openBatterySettings();
  //           },
  //           child: const Text("Open Settings"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ---------- PERMISSION ----------

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    final service = NotificationService();

    if (!await service.canScheduleExactAlarms()) {
      await service.openExactAlarmSettings();
    }

    // Future.delayed(const Duration(milliseconds: 500), () {
    //   showBatteryDialog();
    // });
  }

  // ---------- LOAD SAVED TIME ----------

  Future<void> _loadReminder() async {
    final saved = await AppStorage.getReminderTime();

    if (saved != null) {
      final parts = saved.split(":");

      setState(() {
        selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      });
    }
  }

  // ---------- PICK TIME ----------

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  // ---------- SAVE + SCHEDULE ----------

  Future<void> saveReminder() async {
    try {
      final timeString =
          "${selectedTime.hour}:${selectedTime.minute}";

      await AppStorage.saveReminderTime(timeString);

      await NotificationService().scheduleDailyReminder(timeString);

    } catch (e) {
      debugPrint("Notification error: $e");
    }

    if (!mounted) return;

    context.go('/preview');
  }

  // ---------- UI ----------

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

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/fixed-items');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Reminder",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Get notified to pack your bag",
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 40),

                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Reminder Time",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: pickTime,
                          icon: const Icon(Icons.access_time, size: 20),
                          label: const Text(
                            "Change Time",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveReminder,
                    child: const Text("Continue"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}