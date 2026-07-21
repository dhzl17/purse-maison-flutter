/// Named routes for every screen in the app.
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
