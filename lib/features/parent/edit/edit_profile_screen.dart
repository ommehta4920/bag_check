import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';
import '../../../data/models/child_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();

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

  // ---------- LOAD EXISTING DATA ----------
  Future<void> _loadProfile() async {
    final data = await AppStorage.getChildProfile();

    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? '';
        selectedClass = data['class']?.toString() ?? "1";
        selectedBoard = data['board'] ?? "CBSE";
        selectedDays = List<String>.from(
          data['schoolDays'] ??
              ["Mon", "Tue", "Wed", "Thu", "Fri"],
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

  // ---------- SAVE ----------
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

    /// ✅ SAVE PROFILE
    await AppStorage.saveChildProfile(child.toMap());

    /// 🔥 IMPORTANT: CLEAR OLD CHECKLISTS
    await AppStorage.clearAllDailyChecklists();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );

    context.pop(); // return to dashboard
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ---------- UI HELPERS ----------
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

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                /// HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Edit Child Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// NAME
                          sectionTitle("Child Name"),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "Enter name",
                              filled: true,
                              fillColor:
                              Colors.white.withValues(alpha: 0.08),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// CLASS
                          sectionTitle("Class"),
                          const SizedBox(height: 10),
                          Wrap(
                            children: classes.map(classChip).toList(),
                          ),

                          const SizedBox(height: 20),

                          /// BOARD
                          sectionTitle("Board"),
                          const SizedBox(height: 10),
                          Row(
                            children: boards.map((b) {
                              final isSelected =
                                  selectedBoard == b;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                          () => selectedBoard = b),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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

                          const SizedBox(height: 20),

                          /// DAYS
                          sectionTitle("School Days"),
                          const SizedBox(height: 10),
                          Wrap(
                            children: days.map(dayChip).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text("Save Changes"),
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