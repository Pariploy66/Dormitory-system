import 'package:flutter/material.dart';
import '../theme/mfu_theme.dart';

/// Shared red AppBar with MFU seal + title used on Dashboard & History
class MfuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MfuAppBar({super.key, this.showBack = false, this.actions});

  final bool showBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MfuTheme.primary,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      titleSpacing: showBack ? 0 : 16,
      title: Row(
        children: [
          _MfuSeal(size: 34),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('MFU Dormitory',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2)),
              Text('Dormitory Management System',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 10, height: 1.2)),
            ],
          ),
        ],
      ),
      actions: actions,
    );
  }
}

class _MfuSeal extends StatelessWidget {
  final double size;
  const _MfuSeal({required this.size});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _SealPainter(),
      );
}

class _SealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = s.width / 2;
    final cy = s.height / 2;
    canvas.drawCircle(Offset(cx, cy), s.width * .46,
        p..color = Colors.white.withOpacity(.15));
    canvas.drawCircle(Offset(cx, cy), s.width * .30,
        p..color = Colors.white.withOpacity(.25));
    // Crown / triangle
    final path = Path()
      ..moveTo(cx, cy - s.height * .38)
      ..lineTo(cx + s.width * .20, cy - s.height * .05)
      ..lineTo(cx - s.width * .20, cy - s.height * .05)
      ..close();
    canvas.drawPath(path, p..color = Colors.white.withOpacity(.90));
    canvas.drawCircle(Offset(cx, cy + s.height * .12), s.width * .12,
        p..color = Colors.white.withOpacity(.85));
  }

  @override
  bool shouldRepaint(_) => false;
}
