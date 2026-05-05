import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChildHeader extends StatelessWidget {
  final String day;
  final int streak;

  const ChildHeader({
    super.key,
    required this.day,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// 📅 TITLE
        Text(
          "Bag for $day",
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

        /// 🔥 ACTIONS
        Row(
          children: [

            /// 🔥 STREAK PILL
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                /// gradient highlight
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.25),
                    Colors.deepOrange.withValues(alpha: 0.2),
                  ],
                ),

                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.4),
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$streak",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// 🔒 LOCK BUTTON (GLASS STYLE)
            GestureDetector(
              onTap: () => context.push('/parent-pin'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}