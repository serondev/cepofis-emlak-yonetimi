import 'package:flutter/material.dart';
import 'package:cepofis/utils/responsive_utils.dart';

class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      padding: EdgeInsets.all(ResponsiveUtils.getChipPadding(context)),
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getChipFontSize(context),
        ),
      ),
      avatar: Icon(
        icon,
        size: ResponsiveUtils.getIconSize(context),
      ),
    );
  }
} 