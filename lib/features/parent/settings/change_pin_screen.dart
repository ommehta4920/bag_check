import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/local_db/app_storage.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String pin = "";
  String confirmPin = "";
  bool isConfirming = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _focusNode.requestFocus();
    });
  }

  void _onChanged(String value) {
    if (!isConfirming) {
      pin = value;

      if (pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            isConfirming = true;
            _controller.clear();
          });
        });
      }
    } else {
      confirmPin = value;

      if (confirmPin.length == 4) {
        _validatePin();
      }
    }

    setState(() {});
  }

  Future<void> _validatePin() async {
    if (pin == confirmPin) {
      await AppStorage.savePin(pin);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PIN updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    } else {
      setState(() {
        pin = "";
        confirmPin = "";
        isConfirming = false;
        _controller.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PINs do not match"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------- PIN BOX UI ----------

  Widget _buildPinBoxes() {
    final active = isConfirming ? confirmPin : pin;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final filled = index < active.length;
          final isActive = index == active.length;

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
                  color:
                  AppColors.primary.withValues(alpha: 0.3),
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
                ? const Text("●",
                style: TextStyle(fontSize: 18))
                : null,
          );
        }),
      ),
    );
  }

  // ---------- BUILD ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                /// 🔹 HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                          Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Change PIN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// 🔐 CARD
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        isConfirming
                            ? "Confirm New PIN"
                            : "Enter New PIN",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isConfirming
                            ? "Re-enter to confirm"
                            : "Secure your parent access",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildPinBoxes(),
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