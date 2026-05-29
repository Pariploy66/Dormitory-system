import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/dorm/bloc/dorm_bloc.dart';
import '../../features/locale/bloc/locale_bloc.dart';
import '../../shared/widgets/info_row.dart';

/// Full-screen account info page — name, phone, email.
/// Dispatches DormFetchProfile on entry (guarded: skipped if already loaded).
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DormBloc>().add(const DormFetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD61A22),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(s.account,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<DormBloc, DormState>(
        builder: (context, state) {
          if (state.profileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.black26),
                  const SizedBox(height: 12),
                  Text(state.error ?? s.failedToLoad,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final profile = state.profile!;
          return ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFD61A22),
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(profile.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(s.accountInfo,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black45)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: s.name,
                        value: profile.name),
                    const Divider(
                        height: 1, indent: 56, color: Colors.black12),
                    InfoRow(
                        icon: Icons.phone_outlined,
                        label: s.phone,
                        value: profile.phone),
                    const Divider(
                        height: 1, indent: 56, color: Colors.black12),
                    InfoRow(
                        icon: Icons.email_outlined,
                        label: s.email,
                        value: profile.email),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
