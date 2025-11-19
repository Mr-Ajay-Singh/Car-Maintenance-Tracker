import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/dashboard_summary_model.dart';
import '../service/dashboard_service.dart';
import 'widgets/expense_summary_widget.dart';
import 'widgets/fuel_summary_widget.dart';
import 'widgets/recent_activity_widget.dart';
import 'widgets/upcoming_reminders_widget.dart';
import 'widgets/vehicle_summary_widget.dart';

/// DashboardPage - Main landing page with overview of all features
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  DashboardSummaryModel? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        setState(() {
          _error = 'No user logged in';
          _isLoading = false;
        });
        return;
      }

      final summary = await _dashboardService.getDashboardSummary(userId);
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_summary == null) {
      return const Scaffold(
        body: Center(child: Text('No data available')),
      );
    }

    // If no vehicles, show welcome screen
    if (_summary!.vehicles.isEmpty) {
      return Scaffold(body: _buildWelcomeScreen());
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Vehicles summary
                  Text(
                    'My Vehicles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ..._summary!.vehicles.map((vehicle) => VehicleSummaryWidget(
                        vehicle: vehicle,
                        onTap: () => context.go('/vehicles/${vehicle.vehicleId}'),
                      )),
                  const SizedBox(height: 24),

                  // Upcoming reminders
                  if (_summary!.upcomingReminders.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Reminders',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/reminders'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    UpcomingRemindersWidget(reminders: _summary!.upcomingReminders),
                    const SizedBox(height: 24),
                  ],

                  // Fuel and Expense summary cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_summary!.fuelSummary != null)
                        Expanded(
                          child: FuelSummaryWidget(summary: _summary!.fuelSummary!),
                        ),
                      if (_summary!.fuelSummary != null &&
                          _summary!.expenseSummary != null)
                        const SizedBox(width: 16),
                      if (_summary!.expenseSummary != null)
                        Expanded(
                          child:
                              ExpenseSummaryWidget(summary: _summary!.expenseSummary!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent activity
                  if (_summary!.recentActivities.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/service'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RecentActivityWidget(activities: _summary!.recentActivities),
                  ],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to CarLog!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start by adding your first vehicle to track maintenance, fuel, and expenses.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/vehicles/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Vehicle'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
