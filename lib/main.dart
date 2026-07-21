import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'screens/client_assignment_page.dart';
import 'screens/consignment_management_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/help_page.dart';
import 'screens/inventory_management_page.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/sales_forecasting_page.dart';
import 'screens/logout_page.dart';
import 'screens/settings_page.dart';
import 'theme/app_colors.dart';
import 'widgets/route_guard.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PurseMaisonApp());
}

class PurseMaisonApp extends StatelessWidget {
  const PurseMaisonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purse Maison',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sidebarBg,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: AppRoutes.landing,
      routes: {
        AppRoutes.landing: (context) => const LandingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.dashboard: (context) => const RouteGuard(
          routeName: AppRoutes.dashboard,
          child: DashboardPage(),
        ),
        AppRoutes.consignmentManagement: (context) => const RouteGuard(
          routeName: AppRoutes.consignmentManagement,
          child: ConsignmentManagementPage(),
        ),
        AppRoutes.inventoryManagement: (context) => const RouteGuard(
          routeName: AppRoutes.inventoryManagement,
          child: InventoryManagementPage(),
        ),
        AppRoutes.clientAssignment: (context) => const RouteGuard(
          routeName: AppRoutes.clientAssignment,
          child: ClientAssignmentPage(),
        ),
        AppRoutes.salesForecasting: (context) => const RouteGuard(
          routeName: AppRoutes.salesForecasting,
          child: SalesForecastingPage(),
        ),
        AppRoutes.settings: (context) => const RouteGuard(
          routeName: AppRoutes.settings,
          child: SettingsPage(),
        ),
        AppRoutes.logout: (context) => const RouteGuard(
          routeName: AppRoutes.logout,
          child: LogoutPage(),
        ),
        AppRoutes.help: (context) =>
            const RouteGuard(routeName: AppRoutes.help, child: HelpPage()),
      },
    );
  }
}
