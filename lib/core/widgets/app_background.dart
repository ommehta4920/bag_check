import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Base Gradient
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

        // 🔵 Soft Glow (Top Right)
        Positioned(
          top: -80,
          right: -60,
          child: _buildGlow(
            color: AppColors.primary.withValues(alpha: 0.15),
            size: 200,
          ),
        ),

        // 🟢 Soft Glow (Bottom Left)
        Positioned(
          bottom: -100,
          left: -80,
          child: _buildGlow(
            color: AppColors.secondary.withValues(alpha: 0.12),
            size: 220,
          ),
        ),

        // 📦 Content
        SafeArea(child: child),
      ],
    );
  }

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