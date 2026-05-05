import 'package:flutter/material.dart';

class ProgressSection extends StatelessWidget {
  final int total;
  final int completed;

  const ProgressSection({
    super.key,
    required this.total,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$completed of $total packed",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white12,
          ),
        ),
      ],
    );
  }
}