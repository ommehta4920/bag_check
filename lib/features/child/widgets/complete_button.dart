import 'package:flutter/material.dart';

class CompleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CompleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text("Bag is Ready!"),
      ),
    );
  }
}