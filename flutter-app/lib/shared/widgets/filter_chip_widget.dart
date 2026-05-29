import 'package:flutter/material.dart';

/// Tappable filter chip — used by HistoryScreen for period and type filters.
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasArrow;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.hasArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFD61A22), Color(0xFFA31219)])
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? Colors.transparent : Colors.black12,
              width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: const Color(0xFFD61A22).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black87)),
            if (hasArrow) ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isActive ? Colors.white : Colors.black87),
            ],
          ],
        ),
      ),
    );
  }
}
