import 'package:flutter/material.dart';

/// Error state shown when a data fetch fails.
class ErrorView extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 52, color: Color(0xFFD61A22)),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD61A22)),
              ),
            ],
          ),
        ),
      );
}
