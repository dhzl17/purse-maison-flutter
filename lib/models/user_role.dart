import '../routes/app_routes.dart';

/// The three login roles for the app. Role is set at login time (see
/// AppSession) and controls which routes a user can reach and whether
/// certain pages are view-only.
enum UserRole { superAdmin, operationalStaff, salesAssociate }

extension UserRoleAccess on UserRole {
  /// Label shown in the login page's role selector and anywhere else the
  /// role needs to be displayed (e.g. a "Logged in as ..." badge).
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin (Owner)';
      case UserRole.operationalStaff:
        return 'Operational Staff';
      case UserRole.salesAssociate:
        return 'Sales Associate';
    }
  }

  /// Every route this role is allowed to open. RouteGuard checks incoming
  /// route names against this set; PlaceholderPage handles routes (like
  /// Help) that don't have a dedicated screen yet.
  Set<String> get allowedRoutes {
    switch (this) {
      case UserRole.superAdmin:
        // Full access — every route in the app.
        return {
          AppRoutes.landing,
          AppRoutes.login,
          AppRoutes.dashboard,
          AppRoutes.consignmentManagement,
          AppRoutes.inventoryManagement,
          AppRoutes.clientAssignment,
          AppRoutes.salesForecasting,
          AppRoutes.settings,
          AppRoutes.logout,
          AppRoutes.help,
        };
      case UserRole.operationalStaff:
        return {
          AppRoutes.landing,
          AppRoutes.login,
          AppRoutes.dashboard,
          AppRoutes.consignmentManagement,
          AppRoutes.inventoryManagement,
          AppRoutes.settings,
          AppRoutes.logout,
          AppRoutes.help,
        };
      case UserRole.salesAssociate:
        return {
          AppRoutes.landing,
          AppRoutes.login,
          AppRoutes.dashboard,
          AppRoutes.clientAssignment,
          AppRoutes.inventoryManagement,
          AppRoutes.logout,
          AppRoutes.settings,
          AppRoutes.help,
        };
    }
  }

  bool canAccess(String routeName) => allowedRoutes.contains(routeName);

  /// Sales Associates see Inventory Management in view-only mode (no
  /// add/edit/delete controls). Pass this into InventoryManagementPage
  /// once it accepts a viewOnly flag.
  bool get inventoryIsViewOnly => this == UserRole.salesAssociate;

  /// Sales Associates see Sales Forecasting in view-only mode as well.
  bool get salesForecastingIsViewOnly => this == UserRole.salesAssociate;
}
