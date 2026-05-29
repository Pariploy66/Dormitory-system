import 'package:flutter/material.dart';

/// MFU-branded white app bar with logo + subtitle.
/// Shared across Dashboard, History, and Settings screens.
class MfuCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  const MfuCustomAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(85);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/mfu_logo.png',
            height: 50,
            width: 44,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) =>
                const Icon(Icons.image_not_supported,
                    size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MFU Dormitory',
                    style: TextStyle(
                        color: Color(0xFFC00000),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2)),
                Text('Dormitory Management System',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
