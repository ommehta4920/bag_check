import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),

        /// 🌫️ OUTER BORDER GRADIENT (white → grey)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.6),  // highlight side
            Colors.grey.withValues(alpha: 0.2),   // shadow side
          ],
        ),

        /// 🌑 SOFT SHADOW (very light)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      /// INNER CONTAINER (actual content)
      child: Container(
        margin: const EdgeInsets.all(1.2), // 👈 border thickness
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - 1),

          /// ✅ TRANSPARENT / LIGHT BG
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: child,
      ),
    );
  }
}