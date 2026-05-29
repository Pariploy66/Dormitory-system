import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/locale/bloc/locale_bloc.dart';
import '../../core/theme/mfu_theme.dart';
import '../../core/di/service_locator.dart';

/// Register screen — BLoC pattern.
/// Uses authRepository directly for register (no AuthBloc event needed
/// since registration doesn't change auth state — user must login after).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final s = context.read<LocaleBloc>().state.strings;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await authRepository.register(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go('/login');
    } catch (e) {
      final code = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _error = code == 'NETWORK_ERROR'
            ? s.networkError
            : code == 'ALREADY_REGISTERED'
                ? s.alreadyRegistered
                : code == 'WRONG_CREDENTIALS'
                    ? s.validationError
                    : s.serverError;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
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
                  final digits =
                      v.trim().replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 10 || !digits.startsWith('0')) {
                    return 'กรอกเบอร์โทรศัพท์ไทย 10 หลัก (เช่น 0812345678)';
                  }
                  return null;
                }),
                const SizedBox(height: 14),
                _field(_emailCtrl, s.email, Icons.email_outlined,
                    TextInputType.emailAddress),
                const SizedBox(height: 14),
                _field(
                    _passCtrl,
                    s.passwordHint,
                    Icons.lock_outline_rounded,
                    TextInputType.visiblePassword,
                    obscure: true,
                    minLength: 8,
                    customError: s.passwordHint),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(s.loginLink,
                      style: const TextStyle(
                          fontSize: 12, color: MfuTheme.primary)),
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
