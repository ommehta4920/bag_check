import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/checklist_item.dart';

class ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onTap;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 4), // 🔽 reduced
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10, // 🔽 reduced
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // slightly tighter
        color: item.isChecked
            ? AppColors.success.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(
          color: item.isChecked
              ? AppColors.success
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: item.isChecked
                  ? const Icon(
                Icons.check_circle,
                key: ValueKey(1),
                color: Colors.green,
                size: 18, // 🔽 smaller
              )
                  : const Icon(
                Icons.radio_button_unchecked,
                key: ValueKey(2),
                size: 18, // 🔽 smaller
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14, // 🔽 reduced
                  fontWeight: FontWeight.w500,
                  decoration:
                  item.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}