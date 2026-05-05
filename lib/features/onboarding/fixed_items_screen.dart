import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/constants/fixed_items.dart';
import '../../../data/local_db/app_storage.dart';

class FixedItemsScreen extends StatefulWidget {
  const FixedItemsScreen({super.key});

  @override
  State<FixedItemsScreen> createState() => _FixedItemsScreenState();
}

class _FixedItemsScreenState extends State<FixedItemsScreen> {
  List<String> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    bool hasItems = await AppStorage.hasFixedItems();

    if (hasItems) {
      items = await AppStorage.getFixedItems();
    } else {
      items = List.from(FixedItemsDefaults.items);
    }

    setState(() {});
  }

  void addItem() {
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
                color: Colors.white.withValues(alpha: 0.95),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "Add Item",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "e.g. Shoes",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                              setState(() {
                                items.add(text);
                              });
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
        );
      },
    );
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> saveItems() async {
    await AppStorage.saveFixedItems(items);

    // Next step (Reminder)
    context.go('/reminder');
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

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/timetable');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),
                const Text(
                  "Fixed Items",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "These items will be packed every day",
                  style: TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GlassContainer(
                    child: items.isEmpty ?
                        const Center(
                          child: Text(
                            "No Items Added",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ) : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),

                            /// 🔥 Better visibility
                            color: Colors.white,

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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                items[index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              GestureDetector(
                                onTap: () => removeItem(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.08),
                                  ),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: addItem,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.85),
                      elevation: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveItems,
                    child: const Text("Continue"),
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