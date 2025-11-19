import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/vehicle_model.dart';
import '../service/vehicle_service.dart';

/// AddVehiclePage - Form to add a new vehicle
class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _colorController = TextEditingController();

  String _fuelType = 'Gasoline';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _licensePlateController.dispose();
    _odometerController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final vehicle = VehicleModel(
        id: const Uuid().v4(),
        userId: userId,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        vin: _vinController.text.trim().isEmpty ? null : _vinController.text.trim(),
        licensePlate: _licensePlateController.text.trim().isEmpty ? null : _licensePlateController.text.trim(),
        fuelType: _fuelType,
        currentOdometer: int.parse(_odometerController.text.trim()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _vehicleService.addVehicle(vehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add vehicle: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            // Header
            Text(
              'Vehicle Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info Card
            _buildSectionCard(
              context,
              title: 'Basic Info',
              icon: Icons.directions_car_filled_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        decoration: InputDecoration(
                          labelText: 'Make',
                          hintText: 'Toyota',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.branding_watermark_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          labelText: 'Model',
                          hintText: 'Camry',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.model_training_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                            value?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          hintText: '2023',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Required';
                          final year = int.tryParse(value.trim());
                          if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          hintText: 'Black',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.palette_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Technical Specs Card
            _buildSectionCard(
              context,
              title: 'Technical Specs',
              icon: Icons.settings_rounded,
              children: [
                TextFormField(
                  controller: _vinController,
                  decoration: InputDecoration(
                    labelText: 'VIN (Optional)',
                    hintText: '17-character VIN',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.fingerprint_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 17,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licensePlateController,
                  decoration: InputDecoration(
                    labelText: 'License Plate (Optional)',
                    hintText: 'ABC-1234',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.tag_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _fuelType,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.local_gas_station_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Gasoline', child: Text('Gasoline')),
                    DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                    DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                    DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                    DropdownMenuItem(value: 'CNG', child: Text('CNG')),
                    DropdownMenuItem(value: 'LPG', child: Text('LPG')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _fuelType = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Card
            _buildSectionCard(
              context,
              title: 'Current Status',
              icon: Icons.speed_rounded,
              children: [
                TextFormField(
                  controller: _odometerController,
                  decoration: InputDecoration(
                    labelText: 'Current Odometer',
                    suffixText: 'km',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.add_road_rounded),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Required';
                    final odometer = int.tryParse(value.trim());
                    if (odometer == null || odometer < 0) return 'Invalid odometer';
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submit,
        icon: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check_rounded),
        label: Text(_isSubmitting ? 'Saving...' : 'Add Vehicle'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
