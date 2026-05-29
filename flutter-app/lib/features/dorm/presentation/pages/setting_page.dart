import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../locale/bloc/locale_bloc.dart';
import '../../../../core/l10n/strings.dart';
import '../components/setting_tile.dart';
import 'account_screen.dart';

/// Setting page — language switch, account navigation, logout.
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    final isThai =
        context.watch<LocaleBloc>().state.locale.languageCode == 'th';

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Text(s.setting,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(s.accountSecurity,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SettingTile(
                    icon: Icons.person_outline_rounded,
                    label: s.account,
                    subtitle: s.accountInfo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AccountScreen()),
                    ),
                  ),
                  const Divider(
                      height: 1,
                      indent: 50,
                      endIndent: 20,
                      color: Colors.black12),
                  SettingTile(
                    icon: Icons.language_rounded,
                    label: s.language,
                    subtitle:
                        isThai ? s.languageThai : s.languageEnglish,
                    onTap: () => _showLangSheet(context, s, isThai),
                  ),
                  const Divider(
                      height: 1,
                      indent: 50,
                      endIndent: 20,
                      color: Colors.black12),
                  SettingTile(
                    icon: Icons.logout_rounded,
                    label: s.logout,
                    labelColor: const Color(0xFFD61A22),
                    iconColor: const Color(0xFFD61A22),
                    showChevron: false,
                    onTap: () => _confirmLogout(context, s),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLangSheet(
      BuildContext context, AppStrings s, bool isThai) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(s.language,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: const Text('🇺🇸',
                  style: TextStyle(fontSize: 24)),
              title: Text(s.languageEnglish,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: !isThai
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFD61A22))
                  : null,
              onTap: () {
                context
                    .read<LocaleBloc>()
                    .add(const LocaleChanged(Locale('en')));
                Navigator.pop(sheetCtx);
              },
            ),
            ListTile(
              leading:
                  const Text('🇹🇭', style: TextStyle(fontSize: 24)),
              title: Text(s.languageThai,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: isThai
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFFD61A22))
                  : null,
              onTap: () {
                context
                    .read<LocaleBloc>()
                    .add(const LocaleChanged(Locale('th')));
                Navigator.pop(sheetCtx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppStrings s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(s.logoutTitle,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(s.logoutConfirm,
            style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel,
                style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD61A22),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(s.logout),
          ),
        ],
      ),
    );
  }
}
