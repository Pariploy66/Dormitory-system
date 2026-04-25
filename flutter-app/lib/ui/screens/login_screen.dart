import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/api_repository.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Logic unchanged ───────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(apiRepositoryProvider)
          .login(_emailCtrl.text.trim(), _passCtrl.text);
      ref.invalidate(authStateProvider);
      if (mounted) context.go('/home');
    } catch (_) {
      setState(() => _error = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── UI — MFU style ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Wave background at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 80,
              child: CustomPaint(painter: _WavePainter()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // TH/EN top-left
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('TH/EN',
                        style: TextStyle(
                            color: MfuTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),

                const Spacer(),

                // โลโก้อย่างเดียว (ไม่มีวงกลมพื้นหลัง)
                Image.asset(
                  'assets/images/mfu_logo.png', // เปลี่ยนเป็น path ไฟล์โลโก้
                  width: 300, // กำหนดความกว้างตามต้องการ
                  height: 300, // กำหนดความสูงตามต้องการ
                  fit: BoxFit.contain, // ปรับรูปให้พอดี โดยยังรักษาอัตราส่วนไว้
                ),
                const SizedBox(height: 12),

                const Text('Mae Fah Luang University',
                    style: TextStyle(fontSize: 11, color: MfuTheme.textSub)),
                const SizedBox(height: 6),
                Text('MFU Dormitory',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: MfuTheme.primary)),
                const SizedBox(height: 4),
                const Text(
                    'Real-time monitoring of your child\'s dorm activity',
                    style: TextStyle(fontSize: 11, color: MfuTheme.textHint),
                    textAlign: TextAlign.center),

                const Spacer(),

                // Form (email + password)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'อีเมล',
                            prefixIcon: Icon(Icons.email_outlined,
                                size: 18, color: MfuTheme.textHint),
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'กรุณากรอกอีเมลที่ถูกต้อง',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'รหัสผ่าน',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 18, color: MfuTheme.textHint),
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: MfuTheme.textHint),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 8
                              ? null
                              : 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(
                                  color: MfuTheme.primary, fontSize: 12),
                              textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 16),

                        // Login with ThaiID button (main CTA)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MfuTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.credit_card_rounded,
                                    size: 18),
                            label: const Text('Login with Thai Id',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Mae Fah Luang University',
                    style: TextStyle(fontSize: 11, color: MfuTheme.textHint)),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => context.push('/register'),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก',
                      style: TextStyle(fontSize: 12, color: MfuTheme.primary)),
                ),
                const SizedBox(height: 8),
                const Text('For parents only - secure access system',
                    style: TextStyle(fontSize: 10, color: MfuTheme.textHint)),
                const Text('© Mae Fah Luang University',
                    style: TextStyle(fontSize: 10, color: MfuTheme.textHint)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigSealPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = s.width / 2;
    final cy = s.height / 2;
    canvas.drawCircle(Offset(cx, cy), s.width * .42,
        p..color = MfuTheme.primary.withOpacity(.12));
    canvas.drawCircle(Offset(cx, cy), s.width * .28,
        p..color = MfuTheme.primary.withOpacity(.22));
    final path = Path()
      ..moveTo(cx, cy - s.height * .36)
      ..lineTo(cx + s.width * .18, cy - s.height * .04)
      ..lineTo(cx - s.width * .18, cy - s.height * .04)
      ..close();
    canvas.drawPath(path, p..color = MfuTheme.primary);
    canvas.drawCircle(Offset(cx, cy + s.height * .10), s.width * .10,
        p..color = MfuTheme.primary);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (var i = 0; i < 4; i++) {
      final path = Path();
      final y = s.height * (.2 + i * .22);
      path.moveTo(0, y);
      for (double x = 0; x <= s.width; x += 60) {
        path.quadraticBezierTo(x + 30, y - 10, x + 60, y);
      }
      paint.color = MfuTheme.primary.withOpacity(.14 - i * .03);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
