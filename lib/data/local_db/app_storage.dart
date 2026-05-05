import 'package:hive/hive.dart';

class AppStorage {
  static const String boxName = "appBox";

  static Future<Box> openBox() async {
    return await Hive.openBox(boxName);
  }

  // Save PIN
  static Future<void> savePin(String pin) async {
    final box = await openBox();
    await box.put('user_pin', pin);
  }

  // Get PIN
  static Future<String?> getPin() async {
    final box = await openBox();
    return box.get('user_pin');
  }

  // Check if PIN exists
  static Future<bool> hasPin() async {
    final box = await openBox();
    return box.containsKey('user_pin');
  }

  // Save child profile
  static Future<void> saveChildProfile(Map<String, dynamic> data) async {
    final box = await openBox();
    await box.put('child_profile', data);
  }

  // Get Child Profile
  static Future<Map?> getChildProfile() async {
    final box = await openBox();
    return box.get('child_profile');
  }

  // Check if profile exists
  static Future<bool> hasChildProfile() async {
    final box = await openBox();
    return box.containsKey('child_profile');
  }

  // Save Timetable
  static Future<void> saveTimeTable(Map<String, dynamic> data) async {
    final box = await openBox();
    await box.put('timetable', data);
  }

  // Get Timetable
  static Future<Map?> getTimeTable() async {
    final box = await openBox();
    return box.get('timetable');
  }

  // check if timetable exist
  static Future<bool> hasTimeTable() async {
    final box = await openBox();
    return box.containsKey('timetable');
  }

  // Save fixed items
  static Future<void> saveFixedItems(List<String> items) async {
    final box = await openBox();
    await box.put('fixed_items', items);
  }

  // Get fixed items
  static Future<List<String>> getFixedItems() async {
    final box = await openBox();
    return List<String>.from(box.get('fixed_items', defaultValue: []));
  }

  // Check if exists
  static Future<bool> hasFixedItems() async {
    final box = await openBox();
    return box.containsKey('fixed_items');
  }

  // Save reminder Time
  static Future<void> saveReminderTime(String time) async {
    final box = await openBox();
    await box.put('reminder_time', time);
  }

  // Get Reminder Time
  static Future<String?> getReminderTime() async {
    final box = await openBox();
    return box.get('reminder_time');
  }

  // Check Reminder Time Exists
  static Future<bool> hasReminderTime() async {
    final box = await openBox();
    return box.containsKey('reminder_time');
  }

  // Save Daily Checklist
  static Future<void> saveDailyChecklist(String date, List<Map<String, dynamic>> items) async {
    final box = await openBox();
    await box.put('checklist_$date', items);
  }

  // Get Daily Checklist
  static Future<List<Map<String, dynamic>>?> getDailyChecklist(String date) async {
    final box = await openBox();

    final data = box.get('checklist_$date');

    if (data == null) return null;

    try {
      return List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      return [];
    }
  }

  // Streak Save
  static Future<void> saveStreak(int streak, String lastDate) async {
    final box = await openBox();
    await box.put('streak', {
      'count': streak,
      'last_date': lastDate,
    });
  }

  // Streak Get
  static Future<Map?> getStreak() async {
    final box = await openBox();
    return box.get('streak');
  }

  static Future<bool> isDayCompleted(String day) async {
    final box = await Hive.openBox('appBox');
    final completedDays =
    box.get('completed_days', defaultValue: <String>[]) as List;

    return completedDays.contains(day);
  }

  static Future<void> markDayComplete(String day) async {
    final box = await Hive.openBox('appBox');
    final completedDays =
    box.get('completed_days', defaultValue: <String>[]) as List;

    if (!completedDays.contains(day)) {
      completedDays.add(day);
      await box.put('completed_days', completedDays);
    }
  }

  static Future<void> unmarkDayComplete(String day) async {
    final box = await Hive.openBox('appBox');
    final completedDays =
    box.get('completed_days', defaultValue: <String>[]) as List;

    completedDays.remove(day);

    await box.put('completed_days', completedDays);
  }

  static Future<void> clearAllDailyChecklists() async {
    final box = await Hive.openBox('daily_checklists');
    await box.clear();
  }
}
