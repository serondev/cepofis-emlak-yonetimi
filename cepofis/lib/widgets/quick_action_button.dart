import 'package:flutter/material.dart';
import 'package:cepofis/utils/responsive_utils.dart';

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color color;
  final VoidCallback onTap;
  final bool isSmallPhone;
  final double screenWidth;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.iconData,
    required this.color,
    required this.onTap,
    required this.isSmallPhone,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMediumPhone = screenWidth >= 360 && screenWidth < 400;
    final bool isLargePhone = screenWidth >= 400 && screenWidth < 600;
    
    final double iconSize = isSmallPhone ? 22.0 : (isMediumPhone ? 24.0 : (isLargePhone ? 28.0 : 32.0));
    final double padding = isSmallPhone ? 10.0 : (isMediumPhone ? 12.0 : (isLargePhone ? 14.0 : 16.0));
    final double fontSize = isSmallPhone ? 11.0 : (isMediumPhone ? 12.0 : (isLargePhone ? 14.0 : 16.0));
    final double elevation = isSmallPhone ? 2.0 : 4.0;
    
    return Material(
      color: Colors.white,
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding * 0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: color,
                  size: iconSize,
                ),
              ),
              SizedBox(height: padding * 0.6),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF2D3748),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 