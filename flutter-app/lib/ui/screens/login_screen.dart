import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n.dart';
import '../../data/api_repository.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Logic ─────────────────────────────────────────────────────
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

      // Clear all cached provider state so the new session starts fresh.
      // This prevents a previously logged-in parent's student data from
      // appearing briefly when a different parent logs in.
      ref.invalidate(authStateProvider);
      ref.invalidate(studentsProvider);
      ref.invalidate(accessLogsProvider);
      ref.invalidate(selectedStudentProvider);

      if (mounted) context.go('/home');
    } catch (_) {
      final s = ref.read(stringsProvider);
      setState(() => _error = s.wrongCredentials);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleLocale() {
    final current = ref.read(localeProvider);
    ref.read(localeProvider.notifier).state =
        current.languageCode == 'en' ? const Locale('th') : const Locale('en');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── UI ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final locale = ref.watch(localeProvider);
    final isThai = locale.languageCode == 'th';

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
                // Language toggle — top-left
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: _toggleLocale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MfuTheme.primary, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TH',
                              style: TextStyle(
                                color: isThai
                                    ? MfuTheme.primary
                                    : MfuTheme.textHint,
                                fontSize: 12,
                                fontWeight: isThai
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            const Text(' / ',
                                style: TextStyle(
                                    color: MfuTheme.textHint, fontSize: 12)),
                            Text(
                              'EN',
                              style: TextStyle(
                                color: !isThai
                                    ? MfuTheme.primary
                                    : MfuTheme.textHint,
                                fontSize: 12,
                                fontWeight: !isThai
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Image.asset(
                  'assets/images/mfu_logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey),
                ),
                const SizedBox(height: 12),

                const Text('Mae Fah Luang University',
                    style: TextStyle(fontSize: 11, color: MfuTheme.textSub)),
                const SizedBox(height: 6),
                Text(s.loginTitle,
                    style: const TextStyle(
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
                          decoration: InputDecoration(
                            hintText: s.email,
                            prefixIcon: const Icon(Icons.email_outlined,
                                size: 18, color: MfuTheme.textHint),
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : s.email,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: s.password,
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
                              : s.passwordHint,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(_error!,
                              style: const TextStyle(
                                  color: MfuTheme.primary, fontSize: 12),
                              textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 16),

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
                            label: Text(s.loginButton,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
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
                  child: Text(s.registerLink,
                      style: const TextStyle(
                          fontSize: 12, color: MfuTheme.primary)),
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
