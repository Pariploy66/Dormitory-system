import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../bloc/auth_bloc.dart';
import '../../locale/bloc/locale_bloc.dart';
import '../../dorm/bloc/dorm_bloc.dart';
import '../../../core/theme/mfu_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// UnlockScreen — biometric app lock.
// A session restored from secure storage starts LOCKED; the parent verifies
// with the device's fingerprint/face/PIN (local_auth) to enter the app.
// Devices with no screen lock configured are let through (POC-friendly).
// ═══════════════════════════════════════════════════════════════════════════════

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _localAuth = LocalAuthentication();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Prompt immediately on entry.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    final s = context.read<LocaleBloc>().state.strings;
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        // No screen lock configured on this device — cannot local-auth.
        if (mounted) context.read<AuthBloc>().add(const AuthUnlocked());
        return;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: s.unlockSubtitle,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow device PIN/pattern fallback
        ),
      );
      if (ok && mounted) {
        context.read<AuthBloc>().add(const AuthUnlocked());
      }
    } catch (_) {
      // Plugin error (e.g. emulator without lock screen) — fail open for POC.
      if (mounted) context.read<AuthBloc>().add(const AuthUnlocked());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _useThaidInstead() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    context.read<DormBloc>().add(const DormReset());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: MfuTheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fingerprint_rounded,
                      size: 56, color: MfuTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                s.unlockTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.unlockSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _authenticate,
                  icon: const Icon(Icons.lock_open_rounded, size: 20),
                  label: Text(
                    s.unlockButton,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
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
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _useThaidInstead,
                child: Text(
                  s.unlockUseThaid,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
