import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';


class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: _LogoutConfirmationCard(
          onConfirm: () => performLogout(context),
          onCancel: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _LogoutConfirmationCard extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _LogoutConfirmationCard({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      decoration: BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Are you sure you want to log out of your account?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          const Text(
            'You will need to sign in again to access the system.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),
          NavyActionButton(label: 'Log out', onPressed: onConfirm),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cardNavyDark,
                side: const BorderSide(color: AppColors.cardNavyDark),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void performLogout(BuildContext context) {
  AppSession.instance.logout();
  Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
}

Future<void> showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: _LogoutConfirmationCard(
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            performLogout(context);
          },
        ),
      );
    },
  );
}
