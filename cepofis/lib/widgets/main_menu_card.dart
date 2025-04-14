import 'package:flutter/material.dart';
import 'package:cepofis/utils/responsive_utils.dart';

class MainMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSmallPhone;
  final double screenWidth;

  const MainMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isSmallPhone,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMediumPhone = screenWidth >= 360 && screenWidth < 400;
    final bool isLargePhone = screenWidth >= 400 && screenWidth < 600;
    
    final double iconSize = isSmallPhone ? 26.0 : (isMediumPhone ? 28.0 : (isLargePhone ? 32.0 : 36.0));
    final double padding = isSmallPhone ? 10.0 : (isMediumPhone ? 12.0 : (isLargePhone ? 14.0 : 16.0));
    final double fontSize = isSmallPhone ? 13.0 : (isMediumPhone ? 14.0 : (isLargePhone ? 15.0 : 16.0));
    final double elevation = isSmallPhone ? 3.0 : 4.0;
    
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(padding * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: padding * 0.6),
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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