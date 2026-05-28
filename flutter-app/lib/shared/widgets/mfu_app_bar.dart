import 'package:flutter/material.dart';
import '../../core/theme/mfu_theme.dart';

/// Shared MFU-branded AppBar — used on Dashboard & History.
/// Company pattern: shared/widgets/ for reusable UI components.
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
      title: const Row(
        children: [
          _MfuSeal(size: 34),
          SizedBox(width: 10),
          Column(
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
        p..color = Colors.white.withValues(alpha: .15));
    canvas.drawCircle(Offset(cx, cy), s.width * .30,
        p..color = Colors.white.withValues(alpha: .25));
    final path = Path()
      ..moveTo(cx, cy - s.height * .38)
      ..lineTo(cx + s.width * .20, cy - s.height * .05)
      ..lineTo(cx - s.width * .20, cy - s.height * .05)
      ..close();
    canvas.drawPath(path, p..color = Colors.white.withValues(alpha: .90));
    canvas.drawCircle(Offset(cx, cy + s.height * .12), s.width * .12,
        p..color = Colors.white.withValues(alpha: .85));
  }

  @override
  bool shouldRepaint(_) => false;
}
