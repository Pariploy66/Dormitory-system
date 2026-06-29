import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../locale/bloc/locale_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/mfu_theme.dart';
import 'thaid_login_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LoginScreen — ThaID-only sign in.
// Layout: TH/EN toggle · Logo · Title · "Login with ThaID" button.
// Tapping the button opens ThaID in a webview, captures the authorization code,
// and dispatches it to AuthBloc for the token exchange.
// ═══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> _loginWithThaid() async {
    final s = context.read<LocaleBloc>().state.strings;

    // ThaID sign-in uses an in-app webview (webview_flutter), which only works
    // on Android/iOS. On web, fail gracefully instead of crashing.
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ThaID login รองรับเฉพาะแอปมือถือ (Android/iOS)\n'
            'กรุณารันบน emulator หรืออุปกรณ์จริง',
          ),
        ),
      );
      return;
    }

    try {
      final url = await apiService.getThaidLoginUrl();
      if (!mounted) return;
      final code = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => ThaidLoginScreen(authUrl: url)),
      );
      if (code != null && code.isNotEmpty && mounted) {
        context.read<AuthBloc>().add(AuthThaidLoginRequested(code));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.networkError)),
      );
    }
  }

  String _errorMessage(String code) {
    final s = context.read<LocaleBloc>().state.strings;
    switch (code) {
      case 'NETWORK_ERROR':
        return s.networkError;
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
                  child: CustomPaint(painter: _LoginBackgroundPainter()),
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

                  // ── Body ─────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // Logo
                          Center(
                            child: Image.asset(
                              'assets/images/mfu_logo.png',
                              height: 250,
                            ),
                          ),
                          const SizedBox(height: 14),

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
                          const SizedBox(height: 40),

                          // Error message
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state.status == AuthStatus.failure &&
                                  state.error != null) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
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

                          // ThaID login button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final loading =
                                  state.status == AuthStatus.loading;
                              return SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: loading ? null : _loginWithThaid,
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
                                          Icons.verified_user_outlined,
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
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),

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
