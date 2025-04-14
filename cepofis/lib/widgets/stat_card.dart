import 'package:flutter/material.dart';
import 'package:cepofis/utils/responsive_utils.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;
  final Color color;
  final bool isSmallPhone;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
    required this.color,
    required this.isSmallPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(isSmallPhone ? 2 : 4),
      padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallPhone ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: color,
              size: isSmallPhone ? 24 : 28,
            ),
          ),
          SizedBox(width: isSmallPhone ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF718096),
                    fontSize: isSmallPhone ? 12 : 14,
                  ),
                ),
                SizedBox(height: isSmallPhone ? 4 : 8),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF2D3748),
                    fontSize: isSmallPhone ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 