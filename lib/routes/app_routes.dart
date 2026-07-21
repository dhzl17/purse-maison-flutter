/// Named routes for every screen in the app.
///
/// [sidebarOrder] must stay in the same order as the sidebar's nav items
/// (see AppShell.navItems) — index N in the sidebar navigates to
/// sidebarOrder[N]. Note that [landing] is intentionally excluded from
/// [sidebarOrder]: it's the pre-login marketing screen shown before the
/// user enters the dashboard shell, not one of the sidebar destinations.
/// [help] and [logout] are likewise excluded — they're reached from the
/// sidebar's footer tiles, not its main nav list.
class AppRoutes {
  AppRoutes._();

  static const String landing = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String consignmentManagement = '/consignment-management';
  static const String inventoryManagement = '/inventory-management';
  static const String clientAssignment = '/client-assignment';
  static const String salesForecasting = '/sales-forecasting';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String logout = '/logout';

  static const List<String> sidebarOrder = [
    dashboard,
    consignmentManagement,
    inventoryManagement,
    clientAssignment,
    salesForecasting,
    settings,
  ];
}