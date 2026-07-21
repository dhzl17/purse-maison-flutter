import '../routes/app_routes.dart';

enum UserRole { superAdmin, operationalStaff, salesAssociate }

extension UserRoleAccess on UserRole {
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

  bool get inventoryIsViewOnly => this == UserRole.salesAssociate;

  /// Sales Associates see Sales Forecasting in view-only mode as well.
  bool get salesForecastingIsViewOnly => this == UserRole.salesAssociate;
}
