import 'package:flutter/material.dart';

class SnackStackHeader extends StatelessWidget {
  const SnackStackHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.fastfood,
          size: 28,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        Text(
          "SnackStack",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
