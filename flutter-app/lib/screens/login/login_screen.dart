import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/locale/bloc/locale_bloc.dart';
import '../../core/theme/mfu_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LoginScreen — Full-screen login with MFU branding.
// Layout: TH/EN toggle · Logo · Title · Email+Password fields · Thai ID button
// ═══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(_emailCtrl.text.trim(), _passCtrl.text),
        );
  }

  String _errorMessage(String code) {
    final s = context.read<LocaleBloc>().state.strings;
    switch (code) {
      case 'NETWORK_ERROR':
        return s.networkError;
      case 'WRONG_CREDENTIALS':
        return s.wrongCredentials;
      default:
        return s.serverError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final isTh = context.watch<LocaleBloc>().state.locale.languageCode == 'th';

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: CustomPaint(
                    painter: _LoginBackgroundPainter(),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Language toggle ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _LangToggle(isTh: isTh),
                    ),
                  ),

                  // ── Scrollable body ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 12),

                            // Logo
                            Center(
                              child: Image.asset(
                                'assets/images/mfu_logo.png',
                                height: 250,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // University name
                            const Center(
                              child: Text(
                                'Mae Fah Luang University',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // App title
                            const Center(
                              child: Text(
                                'MFU Dormitory',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: MfuTheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Subtitle
                            Center(
                              child: Text(
                                s.loginSubtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email field
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: s.email,
                                filled: true,
                                fillColor: const Color(0xFFF7F7F7),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                prefixIcon: const Icon(
                                    Icons.email_outlined, size: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return s.email;
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return s.email;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Password field
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                hintText: s.password,
                                filled: true,
                                fillColor: const Color(0xFFF7F7F7),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: MfuTheme.textHint,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return s.password;
                                return null;
                              },
                            ),

                            // Error message
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state.status == AuthStatus.failure &&
                                    state.error != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      _errorMessage(state.error!),
                                      style: const TextStyle(
                                        color: MfuTheme.primary,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final loading =
                                    state.status == AuthStatus.loading;
                                return SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: loading ? null : _submit,
                                    icon: loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.credit_card_rounded,
                                            size: 20,
                                          ),
                                    label: Text(
                                      s.loginButton,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MfuTheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Footer
                            const Center(
                              child: Text(
                                'Mae Fah Luang University',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                            ),

                            // Register link
                            Center(
                              child: TextButton(
                                onPressed: () => context.push('/register'),
                                child: Text(
                                  s.registerLink,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: MfuTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // For-parents footer
                            Center(
                              child: Text(
                                s.forParentsOnly,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Language Toggle Chip ─────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final bool isTh;
  const _LangToggle({required this.isTh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context
                .read<LocaleBloc>()
                .add(const LocaleChanged(Locale('th'))),
            child: Text(
              'TH',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isTh ? FontWeight.w700 : FontWeight.w400,
                color: isTh ? Colors.black87 : Colors.black38,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '/',
              style: TextStyle(fontSize: 12, color: Colors.black26),
            ),
          ),
          GestureDetector(
            onTap: () => context
                .read<LocaleBloc>()
                .add(const LocaleChanged(Locale('en'))),
            child: Text(
              'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: !isTh ? FontWeight.w700 : FontWeight.w400,
                color: !isTh ? Colors.black87 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0x22B71C1C)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final backgroundPath = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.25,
          size.width * 0.5, size.height * 0.45)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.65, size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backgroundPath, backgroundPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x2EB71C1C);

    for (var i = 0; i <= 7; i++) {
      final offset = i / 7;
      final path = Path()
        ..moveTo(0, size.height * (0.65 - offset * 0.15))
        ..cubicTo(
          size.width * 0.25,
          size.height * (0.65 - offset * 0.22),
          size.width * 0.75,
          size.height * (0.35 - offset * 0.18),
          size.width,
          size.height * (0.45 - offset * 0.16),
        );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
