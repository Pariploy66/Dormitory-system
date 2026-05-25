import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n.dart';
import '../../data/api_repository.dart';
import '../../providers/app_providers.dart';
import '../theme/mfu_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ── Logic unchanged ───────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(apiRepositoryProvider).register(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
      // Redirect to login — do NOT auto-login to avoid stale-state bugs
      if (mounted) context.go('/login');
    } on DioException catch (e) {
      final s = ref.read(stringsProvider);
      final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      final status = e.response?.statusCode;
      setState(() {
        _error = isNetworkError
            ? s.networkError
            : status == 409
                ? s.alreadyRegistered   // email / phone duplicate
                : status == 400
                    ? s.validationError // DTO validation failed (e.g. phone format)
                    : s.serverError;
      });
    } catch (_) {
      final s = ref.read(stringsProvider);
      setState(() => _error = s.serverError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── UI — MFU style ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      backgroundColor: MfuTheme.bgPage,
      appBar: AppBar(
        backgroundColor: MfuTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(s.registerTitle,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _field(_nameCtrl, s.name, Icons.person_outline_rounded,
                    TextInputType.name),
                const SizedBox(height: 14),
                _field(_phoneCtrl, s.phone, Icons.phone_outlined,
                    TextInputType.phone,
                    customValidator: (v) {
                      if (v == null || v.trim().isEmpty) return s.phone;
                      final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 10 || !digits.startsWith('0')) {
                        return 'กรอกเบอร์โทรศัพท์ไทย 10 หลัก (เช่น 0812345678)';
                      }
                      return null;
                    }),
                const SizedBox(height: 14),
                _field(_emailCtrl, s.email, Icons.email_outlined,
                    TextInputType.emailAddress),
                const SizedBox(height: 14),
                _field(_passCtrl, s.passwordHint,
                    Icons.lock_outline_rounded, TextInputType.visiblePassword,
                    obscure: true, minLength: 8, customError: s.passwordHint),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!,
                      style: const TextStyle(
                          color: MfuTheme.primary, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MfuTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(s.registerButton,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(s.loginLink,
                      style: const TextStyle(fontSize: 12, color: MfuTheme.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    TextInputType type, {
    bool obscure = false,
    int minLength = 2,
    String? customError,
    String? Function(String?)? customValidator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: MfuTheme.textHint),
      ),
      validator: customValidator ??
          (v) {
            if (v == null || v.trim().isEmpty) return customError ?? hint;
            if (v.trim().length < minLength) return customError ?? hint;
            return null;
          },
    );
  }
}
