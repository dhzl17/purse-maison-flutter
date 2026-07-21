import 'package:flutter/material.dart';

import '../models/nav_item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import 'app_sidebar.dart';
import 'top_bar.dart';

/// Common page chrome shared by every screen: the navy sidebar (permanent
/// rail on wide screens, a Drawer on narrow ones) plus the fixed top bar.
///
/// Each screen just supplies its own scrollable [body] and tells the shell
/// which sidebar item is currently active via [selectedIndex]. Tapping a
/// different sidebar item navigates to that screen's named route — see
/// AppRoutes.
class AppShell extends StatefulWidget {
  final int selectedIndex;
  final Widget body;
  final bool initiallyShowSidebar;

  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.body,
    this.initiallyShowSidebar = true,
  });

  /// Sidebar items, in display order. Index N here corresponds to
  /// AppRoutes.sidebarOrder[N].
  static const List<NavItemData> navItems = [
    NavItemData(Icons.dashboard, 'Dashboard'),
    NavItemData(Icons.store, 'Consignment Management'),
    NavItemData(Icons.inventory_2, 'Inventory Management'),
    NavItemData(Icons.people, 'Client Assignment'),
    NavItemData(Icons.trending_up, 'Sales Forecasting'),
    NavItemData(Icons.settings, 'Settings'),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late bool _showSidebar;

  @override
  void initState() {
    super.initState();
    _showSidebar = widget.initiallyShowSidebar;
  }

  void _handleNavSelect(BuildContext context, int index) {
    if (index == widget.selectedIndex) return; // already on this page
    Navigator.of(context).pushReplacementNamed(AppRoutes.sidebarOrder[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint: below 1000px wide, the sidebar collapses into a Drawer.
        final bool isWide = constraints.maxWidth >= 1000;
        final bool showPersistentSidebar = isWide && _showSidebar;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          drawer: isWide
              ? null
              : Drawer(
                  child: AppSidebar(
                    selectedIndex: widget.selectedIndex,
                    navItems: AppShell.navItems,
                    onSelect: (i) {
                      // Close the drawer, then navigate to the new page.
                      Navigator.of(context).pop();
                      _handleNavSelect(context, i);
                    },
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (showPersistentSidebar)
                  AppSidebar(
                    selectedIndex: widget.selectedIndex,
                    navItems: AppShell.navItems,
                    onSelect: (i) => _handleNavSelect(context, i),
                  ),
                Expanded(
                  // Builder gives us a context below the Scaffold so
                  // Scaffold.of(...) can find it to open the Drawer.
                  child: Builder(
                    builder: (innerContext) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                            child: TopBar(
                              showMenuButton: true,
                              onMenuTap: () {
                                if (isWide) {
                                  setState(() => _showSidebar = !_showSidebar);
                                } else {
                                  Scaffold.of(innerContext).openDrawer();
                                }
                              },
                            ),
                          ),
                          // Every page's content sits inside this same soft
                          // rounded panel — matches the reference design's
                          // consistent outer framing across all screens.
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.panelBackground,
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: widget.body,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
