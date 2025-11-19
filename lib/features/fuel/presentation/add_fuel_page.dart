import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/fuel_entry_model.dart';
import '../service/fuel_entry_service.dart';
import '../../vehicle/service/vehicle_service.dart';
import '../../vehicle/data/models/vehicle_model.dart';

class AddFuelPage extends StatefulWidget {
  final String? vehicleId;
  const AddFuelPage({super.key, this.vehicleId});

  @override
  State<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends State<AddFuelPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = FuelEntryService();
  
  final _volumeController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _isFullTank = true;
  DateTime _selectedDate = DateTime.now();
  
  // Vehicle selection
  List<dynamic> _vehicles = [];
  String? _selectedVehicleId;
  bool _isLoadingVehicles = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
    if (_selectedVehicleId == null) {
      _loadVehicles();
    }
  }



  @override
  void dispose() {
    _volumeController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoadingVehicles = true);
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        final vehicleService = VehicleService();
        final vehicles = await vehicleService.getAllVehicles(userId);
        setState(() {
          _vehicles = vehicles;
          if (vehicles.isNotEmpty) {
            _selectedVehicleId = vehicles.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading vehicles: $e');
    } finally {
      if (mounted) setState(() => _isLoadingVehicles = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) throw Exception('No user logged in');

      final volume = double.parse(_volumeController.text.trim());
      final cost = double.parse(_costController.text.trim());

      final entry = FuelEntryModel(
        id: const Uuid().v4(),
        vehicleId: _selectedVehicleId!,
        userId: userId,
        date: _selectedDate,
        odometer: int.parse(_odometerController.text.trim()),
        volume: volume,
        cost: cost,
        pricePerUnit: cost / volume,
        fuelType: 'Gasoline', // Could be dynamic based on vehicle
        isFullTank: _isFullTank,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.addFuelEntry(entry);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fuel entry added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Fuel'),
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
            if (widget.vehicleId == null) ...[
              if (_isLoadingVehicles)
                const Center(child: CircularProgressIndicator())
              else if (_vehicles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No vehicles found. Please add a vehicle first.'),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: 'Vehicle',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.directions_car_rounded),
                  ),
                  items: _vehicles.map<DropdownMenuItem<String>>((v) {
                    return DropdownMenuItem<String>(
                      value: v.id,
                      child: Text('${v.year} ${v.make} ${v.model}'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedVehicleId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              const SizedBox(height: 24),
            ],

            Text(
              'Fuel Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 24),

            // Basic Info Card
            _buildSectionCard(
              context,
              title: 'Fill-up Info',
              icon: Icons.local_gas_station_rounded,
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _volumeController,
                        decoration: InputDecoration(
                          labelText: 'Volume',
                          suffixText: 'L',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.opacity_rounded),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v?.trim().isEmpty == true) return 'Required';
                          final val = double.tryParse(v!.trim());
                          if (val == null || val <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        decoration: InputDecoration(
                          labelText: 'Total Cost',
                          prefixText: '\$',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v?.trim().isEmpty == true) return 'Required';
                          final val = double.tryParse(v!.trim());
                          if (val == null || val < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Odometer Card
            _buildSectionCard(
              context,
              title: 'Vehicle Status',
              icon: Icons.speed_rounded,
              children: [
                TextFormField(
                  controller: _odometerController,
                  decoration: InputDecoration(
                    labelText: 'Odometer',
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
                  validator: (v) {
                    if (v?.trim().isEmpty == true) return 'Required';
                    final val = int.tryParse(v!.trim());
                    if (val == null || val < 0) return 'Invalid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Full Tank'),
                  subtitle: const Text('Required for accurate MPG calculation'),
                  value: _isFullTank,
                  onChanged: (v) => setState(() => _isFullTank = v),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isFullTank 
                          ? colorScheme.primaryContainer 
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.battery_full_rounded,
                      color: _isFullTank 
                          ? colorScheme.onPrimaryContainer 
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
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
        label: Text(_isSubmitting ? 'Saving...' : 'Save Entry'),
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
