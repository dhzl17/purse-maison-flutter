import 'package:flutter/material.dart';

import '../models/nav_item.dart';
import '../routes/app_routes.dart';
import '../screens/logout_page.dart';
import '../theme/app_colors.dart';

/// Dark navy navigation rail with logo, nav links, and a footer
/// (Log Out / Help). Used both as a permanent rail (wide screens) and
/// inside a Drawer (narrow screens) — see AppShell.
class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<NavItemData> navItems;
  final ValueChanged<int> onSelect;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.sidebarBg,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildLogo(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = navItems[index];
                    return SidebarNavTile(
                      icon: item.icon,
                      label: item.label,
                      selected: index == selectedIndex,
                      onTap: () => onSelect(index),
                    );
                  },
                  childCount: navItems.length,
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  SidebarNavTile(
                    icon: Icons.logout,
                    label: 'Log Out',
                    selected: false,
                    // Quick confirmation dialog rather than navigating away —
                    // see LogoutPage for the full-route version.
                    onTap: () => showLogoutDialog(context),
                  ),
                  SidebarNavTile(
                    icon: Icons.help_outline,
                    label: 'Help',
                    selected: false,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.help),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Purse Maison brand mark used at the top of the navigation rail.
  Widget _buildLogo() {
    return SizedBox(
      width: 112,
      height: 112,
      child: Image.asset(
        'assets/images/LOGO_PURSE_MAISON-removebg-preview.png',
        fit: BoxFit.contain,
        semanticLabel: 'Purse Maison',
      ),
    );
  }
}

/// A single tappable row in the sidebar (nav link or footer action).
class SidebarNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SidebarNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
