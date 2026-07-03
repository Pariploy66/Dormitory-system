import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/locale/bloc/locale_bloc.dart';

/// MFU-branded white app bar with logo + subtitle.
/// Shared across Dashboard, History, and Settings screens.
class MfuCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  /// When true the MFU logo is replaced by a back button (used by multi-child
  /// parents to return to the child-selection screen). [onBack] is invoked on tap.
  final bool showBack;
  final VoidCallback? onBack;

  const MfuCustomAppBar({
    super.key,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(85);

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleBloc>().state.strings;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 15,
        left: 20,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(Icons.arrow_back_rounded,
                  size: 28, color: Color(0xFFC00000)),
            )
          else
            Image.asset(
              'assets/images/mfu_logo.png',
              height: 50,
              width: 44,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) =>
                  const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.loginTitle,
                    style: const TextStyle(
                        color: Color(0xFFC00000),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2)),
                Text(s.appDescription,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
