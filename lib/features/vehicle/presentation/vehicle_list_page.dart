import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/vehicle_model.dart';
import '../service/vehicle_service.dart';
import '../../../common/utils/format_helper.dart';

/// VehicleListPage - List of all user vehicles
class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final VehicleService _vehicleService = VehicleService();
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
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

      final vehicles = await _vehicleService.getAllVehicles(userId);
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load vehicles: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddVehicle() async {
    final result = await context.push<bool>('/vehicles/add');
    if (result == true) {
      _loadVehicles();
    }
  }

  Future<String> _getFormattedOdometer(int odometer) async {
    return await FormatHelper.formatDistance(odometer);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadVehicles,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              floating: true,
              pinned: false,
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _loadVehicles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_vehicles.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 80,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Vehicles Yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first vehicle to get started',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _navigateToAddVehicle,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vehicle'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vehicle = _vehicles[index];
                      return _VehicleCard(
                        vehicle: vehicle,
                        onTap: () async {
                          await context.push('/vehicles/${vehicle.id}');
                          _loadVehicles(); // Refresh on return in case of edits/deletion
                        },
                        getFormattedOdometer: _getFormattedOdometer,
                      );
                    },
                    childCount: _vehicles.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _vehicles.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddVehicle,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final Future<String> Function(int) getFormattedOdometer;

  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.getFormattedOdometer,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.year} ${vehicle.make}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          vehicle.model,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoBadge(
                    icon: Icons.speed_rounded,
                    label: FutureBuilder<String>(
                      future: getFormattedOdometer(vehicle.currentOdometer),
                      builder: (context, snapshot) =>
                          Text(snapshot.data ?? '${vehicle.currentOdometer} km'),
                    ),
                    colorScheme: colorScheme,
                  ),
                  if (vehicle.licensePlate != null && vehicle.licensePlate!.isNotEmpty)
                    _InfoBadge(
                      icon: Icons.tag_rounded,
                      label: Text(vehicle.licensePlate!),
                      colorScheme: colorScheme,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final Widget label;
  final ColorScheme colorScheme;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        DefaultTextStyle(
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          child: label,
        ),
      ],
    );
  }
}
