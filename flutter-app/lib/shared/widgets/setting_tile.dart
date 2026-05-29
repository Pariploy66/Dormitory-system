import 'package:flutter/material.dart';

/// Reusable list tile used in the Settings screen.
class SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;
  final VoidCallback onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.black54).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.black87),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: labelColor ?? Colors.black87)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style:
                  const TextStyle(fontSize: 12, color: Colors.black45))
          : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded,
              size: 20, color: Colors.black38)
          : null,
      onTap: onTap,
    );
  }
}
