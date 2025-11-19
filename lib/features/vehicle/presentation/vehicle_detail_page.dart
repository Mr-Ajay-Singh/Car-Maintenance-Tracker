import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/vehicle_model.dart';
import '../service/vehicle_service.dart';

/// VehicleDetailPage - Detailed view of a specific vehicle
class VehicleDetailPage extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailPage({
    super.key,
    required this.vehicleId,
  });

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final VehicleService _vehicleService = VehicleService();
  VehicleModel? _vehicle;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vehicle = await _vehicleService.getVehicleById(widget.vehicleId);
      setState(() {
        _vehicle = vehicle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load vehicle: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _vehicleService.deleteVehicle(widget.vehicleId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(); // Return to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete vehicle: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error ?? 'Vehicle not found'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _loadVehicle,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(_vehicle!.model),
            centerTitle: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteVehicle,
                tooltip: 'Delete Vehicle',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_vehicle!.year} ${_vehicle!.make}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_vehicle!.currentOdometer} km',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.build_rounded,
                        label: 'Service',
                        color: colorScheme.primary,
                        onTap: () => context.go('/service/add?vehicleId=${widget.vehicleId}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.local_gas_station_rounded,
                        label: 'Fuel',
                        color: colorScheme.secondary,
                        onTap: () => context.go('/fuel/add?vehicleId=${widget.vehicleId}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.notifications_rounded,
                        label: 'Reminder',
                        color: colorScheme.tertiary,
                        onTap: () => context.go('/reminders/add?vehicleId=${widget.vehicleId}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Expense',
                        color: colorScheme.error,
                        onTap: () => context.go('/expenses/add?vehicleId=${widget.vehicleId}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Details Section
                Text(
                  'Vehicle Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.branding_watermark_rounded,
                        label: 'Make',
                        value: _vehicle!.make,
                      ),
                      _DetailRow(
                        icon: Icons.model_training_rounded,
                        label: 'Model',
                        value: _vehicle!.model,
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Year',
                        value: _vehicle!.year.toString(),
                      ),
                      _DetailRow(
                        icon: Icons.local_gas_station_rounded,
                        label: 'Fuel Type',
                        value: _vehicle!.fuelType,
                      ),
                      if (_vehicle!.vin != null && _vehicle!.vin!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.fingerprint_rounded,
                          label: 'VIN',
                          value: _vehicle!.vin!,
                        ),
                      if (_vehicle!.licensePlate != null && _vehicle!.licensePlate!.isNotEmpty)
                        _DetailRow(
                          icon: Icons.tag_rounded,
                          label: 'License Plate',
                          value: _vehicle!.licensePlate!,
                        ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
