import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';
import '../../../data/models/child_model.dart';

class ChildProfileScreen extends StatefulWidget {
  const ChildProfileScreen({super.key});

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String selectedClass = "1";
  String selectedBoard = "CBSE";
  List<String> selectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri"];

  final List<String> classes =
  List.generate(7, (index) => "${index + 1}");

  final List<String> boards = ["CBSE", "State"];
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await AppStorage.getChildProfile();

    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? '';

        selectedClass = data['class']?.toString() ?? "1";
        selectedBoard = data['board'] ?? "CBSE";

        selectedDays = List<String>.from(
          data['schoolDays'] ?? ["Mon", "Tue", "Wed", "Thu", "Fri"],
        );
      });
    }
  }

  void toggleDay(String day) {
    setState(() {
      selectedDays.contains(day)
          ? selectedDays.remove(day)
          : selectedDays.add(day);
    });
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      _showError("Please enter child's name");
      return;
    }

    if (selectedDays.isEmpty) {
      _showError("Select at least one school day");
      return;
    }

    final child = ChildModel(
      name: nameController.text.trim(),
      studentClass: selectedClass,
      board: selectedBoard,
      schoolDays: selectedDays,
    );

    await AppStorage.saveChildProfile(child.toMap());
    context.push('/timetable');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  /// 🔵 Section Title
  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 🔵 Class Chip (small)
  Widget classChip(String value) {
    final isSelected = selectedClass == value;

    return GestureDetector(
      onTap: () => setState(() => selectedClass = value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.7),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// 🔵 Day Chip (perfect circle)
  Widget dayChip(String day) {
    final isSelected = selectedDays.contains(day);

    return GestureDetector(
      onTap: () => toggleDay(day),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.7),
        ),
        child: Text(
          day.substring(0, 1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen =
        MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, // ❌ disable resize
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [

                const SizedBox(height: 20),

                /// 🔵 Progress Bar
                LinearProgressIndicator(
                  value: 0.2, // Step 1 of 5
                  backgroundColor: Colors.white.withValues(alpha: 0.4),
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),

                const SizedBox(height: 30),

                /// 🔵 Title
                const Text(
                  "Child Profile",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Setup details for smart bag planning",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 30),

                /// 👤 Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: sectionTitle("Enter Child Name"),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "e.g. Rahul",
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.7),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                      BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// 🎓 Class
                Align(
                  alignment: Alignment.centerLeft,
                  child: sectionTitle("Class / Standard"),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: classes.map(classChip).toList(),
                ),

                const SizedBox(height: 25),

                /// 🏫 Board
                Align(
                  alignment: Alignment.centerLeft,
                  child: sectionTitle("Board"),
                ),

                const SizedBox(height: 10),

                Row(
                  children: boards.map((b) {
                    final isSelected = selectedBoard == b;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedBoard = b),
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 6),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(20),
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                          child: Center(
                            child: Text(
                              b,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),

                /// 📅 Days
                Align(
                  alignment: Alignment.centerLeft,
                  child: sectionTitle("School Days"),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: days.map(dayChip).toList(),
                ),

                const Spacer(),

                /// 🚀 Continue Button
                if (!isKeyboardOpen)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfile,
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