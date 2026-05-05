import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/local_db/app_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    bool hasPin = await AppStorage.hasPin();
    bool hasProfile = await AppStorage.hasChildProfile();
    bool hasTimetable = await AppStorage.hasTimeTable();
    bool hasFixedItems = await AppStorage.hasFixedItems();
    bool hasReminder = await AppStorage.hasReminderTime();

    if (!hasPin) {
      context.go('/set-pin');
    } else if (!hasProfile) {
      context.go('/child-profile');
    } else if (!hasTimetable) {
      context.go('/timetable');
    } else if (!hasFixedItems) {
      context.go('/fixed-items');
    } else if (!hasReminder) {
      context.go('/reminder');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Base Background (matches AppBackground)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF6F8FC),
                  Color(0xFFEFF6FF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔵 Top Right Glow
          Positioned(
            top: -80,
            right: -60,
            child: _buildGlow(
              color: AppColors.primary.withValues(alpha: 0.12),
              size: 200,
            ),
          ),

          // 🟢 Bottom Left Glow
          Positioned(
            bottom: -100,
            left: -80,
            child: _buildGlow(
              color: AppColors.secondary.withValues(alpha: 0.10),
              size: 220,
            ),
          ),

          // 🎯 Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🎒 Bag Icon Container
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      // Soft shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),

                      // Brand glow
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.backpack, // 🎯 Relevant icon
                    size: 56,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "BagCheck",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Pack Smart. Never Forget.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔮 Glow builder
  Widget _buildGlow({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}