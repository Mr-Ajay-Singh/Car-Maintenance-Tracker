import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/expenses/presentation/add_expense_page.dart';
import '../../features/expenses/presentation/expense_stats_page.dart';
import '../../features/expenses/presentation/expenses_page.dart';
import '../../features/fuel/presentation/add_fuel_page.dart';
import '../../features/fuel/presentation/fuel_list_page.dart';
import '../../features/fuel/presentation/fuel_stats_page.dart';
import '../../features/reminders/presentation/add_reminder_page.dart';
import '../../features/reminders/presentation/reminder_detail_page.dart';
import '../../features/reminders/presentation/reminders_page.dart';
import '../../features/service_log/presentation/add_service_page.dart';
import '../../features/service_log/presentation/service_detail_page.dart';
import '../../features/service_log/presentation/service_list_page.dart';
import '../../features/settings/presentation/about_page.dart';
import '../../features/settings/presentation/preferences_page.dart';
import '../../features/settings/presentation/profile_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/vehicle/presentation/add_vehicle_page.dart';
import '../../features/vehicle/presentation/vehicle_detail_page.dart';
import '../../features/vehicle/presentation/vehicle_list_page.dart';
import '../widgets/main_scaffold.dart';

/// AppRouter - Centralized routing configuration using go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Main scaffold with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Dashboard (Home)
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // Vehicles
          GoRoute(
            path: '/vehicles',
            name: 'vehicles',
            builder: (context, state) => const VehicleListPage(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-vehicle',
                builder: (context, state) => const AddVehiclePage(),
              ),
              GoRoute(
                path: ':vehicleId',
                name: 'vehicle-detail',
                builder: (context, state) {
                  final vehicleId = state.pathParameters['vehicleId']!;
                  return VehicleDetailPage(vehicleId: vehicleId);
                },
              ),
            ],
          ),

          // Service Log
          GoRoute(
            path: '/service',
            name: 'service',
            builder: (context, state) => const ServiceListPage(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-service',
                builder: (context, state) {
                  final vehicleId = state.uri.queryParameters['vehicleId'];
                  return AddServicePage(vehicleId: vehicleId);
                },
              ),
              GoRoute(
                path: ':serviceId',
                name: 'service-detail',
                builder: (context, state) {
                  final serviceId = state.pathParameters['serviceId']!;
                  return ServiceDetailPage(serviceId: serviceId);
                },
              ),
            ],
          ),

          // Reminders
          GoRoute(
            path: '/reminders',
            name: 'reminders',
            builder: (context, state) => const RemindersPage(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-reminder',
                builder: (context, state) {
                  final vehicleId = state.uri.queryParameters['vehicleId'];
                  return AddReminderPage(vehicleId: vehicleId);
                },
              ),
              GoRoute(
                path: ':reminderId',
                name: 'reminder-detail',
                builder: (context, state) {
                  final reminderId = state.pathParameters['reminderId']!;
                  return ReminderDetailPage(reminderId: reminderId);
                },
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
              GoRoute(
                path: 'preferences',
                name: 'preferences',
                builder: (context, state) => const PreferencesPage(),
              ),
              GoRoute(
                path: 'about',
                name: 'about',
                builder: (context, state) => const AboutPage(),
              ),
            ],
          ),
        ],
      ),

      // Fuel (accessed from drawer)
      GoRoute(
        path: '/fuel',
        name: 'fuel',
        builder: (context, state) => const FuelListPage(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-fuel',
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return AddFuelPage(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: 'stats',
            name: 'fuel-stats',
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return FuelStatsPage(vehicleId: vehicleId);
            },
          ),
        ],
      ),

      // Expenses (accessed from drawer)
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensesPage(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-expense',
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return AddExpensePage(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: 'stats',
            name: 'expense-stats',
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return ExpenseStatsPage(vehicleId: vehicleId);
            },
          ),
        ],
      ),
    ],
  );
}
