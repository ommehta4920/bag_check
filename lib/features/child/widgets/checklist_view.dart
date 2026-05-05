import 'package:flutter/material.dart';
import '../../../data/models/checklist_item.dart';
import 'checklist_item_tile.dart';

class ChecklistView extends StatelessWidget {
  final List<ChecklistItem> items;
  final Function(int) onTap;

  const ChecklistView({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6), // tighter
      itemCount: items.length,
      itemBuilder: (_, i) {
        return ChecklistItemTile(
          item: items[i],
          onTap: () => onTap(i),
        );
      },
    );
  }
}