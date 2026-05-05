import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/widgets/app_background.dart';
import '../../core/theme/app_colors.dart';

class SuccessScreen extends StatelessWidget {
  final int streak;

  const SuccessScreen({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// 🎊 Animation
                Lottie.asset(
                  'assets/animations/Confetti.json',
                  height: 220,
                  repeat: false,
                ),

                const SizedBox(height: 10),

                /// 🎉 Title
                const Text(
                  "Awesome Work! 🎉",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                /// Subtitle
                const Text(
                  "Your bag is packed and ready 🎒",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                /// 🔥 Streak Card
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange.withValues(alpha: 0.15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "$streak Day Streak",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// ✅ Done Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    child: const Text("Done"),
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