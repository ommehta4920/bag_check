import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CompletedView extends StatelessWidget {
  final int streak;

  const CompletedView({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// 🎉 ICON + CONFETTI STACK
          Stack(
            alignment: Alignment.center,
            children: [

              /// 🔥 Confetti Background (Infinite)
              SizedBox(
                height: 220,
                width: 220,
                child: Lottie.asset(
                  'assets/animations/Confetti.json',
                  repeat: true,
                  fit: BoxFit.cover,
                ),
              ),

              /// 🏆 Center Premium Icon
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFC107),
                      Color(0xFFFF9800),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 55,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// 🎯 TITLE
          const Text(
            "Mission Complete!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          /// 📄 SUBTEXT
          const Text(
            "Your bag is ready.\n Your parent verified it successfully...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 25),

          /// 🔥 STREAK BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.2),
                  Colors.deepOrange.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  "$streak Day Streak",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}