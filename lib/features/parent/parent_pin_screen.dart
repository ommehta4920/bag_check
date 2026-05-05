import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local_db/app_storage.dart';

class ParentPinScreen extends StatefulWidget {
  final bool isVerification;

  const ParentPinScreen({
    super.key,
    this.isVerification = false,
  });

  @override
  State<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends State<ParentPinScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String pin = "";
  String? error;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  void _onChanged(String value) {
    pin = value;

    if (pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), verifyPin);
    }

    setState(() {});
  }

  Future<void> verifyPin() async {
    final savedPin = await AppStorage.getPin();

    if (pin == savedPin) {
      // ✅ Dismiss keyboard cleanly
      FocusScope.of(context).unfocus();

      await Future.delayed(const Duration(milliseconds: 150));

      final isVerification = GoRouterState.of(context).extra == true;

      if (isVerification) {
        context.pop(true);
      } else {
        context.go('/parent-dashboard');
      }
    } else {
      setState(() {
        error = "Incorrect PIN";
        pin = "";
        _controller.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPinBoxes() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // reset focus
        Future.delayed(const Duration(milliseconds: 50), () {
          _focusNode.requestFocus(); // re-focus properly
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final filled = index < pin.length;
          final isActive = index == pin.length;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 55,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.7),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : filled
                    ? AppColors.primary
                    : AppColors.border,
                width: isActive ? 2 : 1.2,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                )
              ]
                  : [],
            ),
            child: isActive
                ? Container(
              width: 2,
              height: 20,
              color: AppColors.primary,
            )
                : filled
                ? const Text("●", style: TextStyle(fontSize: 18))
                : null,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 HEADER (aligned properly)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      "Parent Access",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// 🔐 CARD
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 40,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Enter PIN",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Secure access for parents",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildPinBoxes(),

                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                /// 🔒 HIDDEN INPUT
                SizedBox(
                  height: 0,
                  width: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    onChanged: _onChanged,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}