import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../routes/app_routes.dart';
import '../services/app_session.dart';
import '../theme/app_colors.dart';

class RouteGuard extends StatelessWidget {
  final String routeName;
  final Widget child;

  const RouteGuard({super.key, required this.routeName, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSession.instance,
      builder: (context, _) {
        final session = AppSession.instance;

        if (session.isInitializing) {
          return const _RedirectingScaffold();
        }

        if (!session.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          });
          return const _RedirectingScaffold();
        }

        final role = session.currentRole!;
        if (!role.canAccess(routeName)) {
          return _AccessDeniedScaffold(roleLabel: role.label);
        }

        return child;
      },
    );
  }
}

class _RedirectingScaffold extends StatelessWidget {
  const _RedirectingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.sidebarBg),
      ),
    );
  }
}

class _AccessDeniedScaffold extends StatelessWidget {
  final String roleLabel;

  const _AccessDeniedScaffold({required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              "You don't have access to this page",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Signed in as $roleLabel',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sidebarBg,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
