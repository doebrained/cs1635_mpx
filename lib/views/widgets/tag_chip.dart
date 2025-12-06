import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class TagChip extends StatelessWidget {
  final String label;

  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AccessibleColors.primary,
          width: 1.5,
        ),
        color: AccessibleColors.primaryLightest,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: AccessibleColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
