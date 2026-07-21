import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final int navIndex;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.navIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: navIndex,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_empty, size: 44, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This section hasn't been built yet — ask for it and it'll show up here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
