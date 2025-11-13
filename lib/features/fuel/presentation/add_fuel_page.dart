import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../common/data/shared_preferences_helper.dart';
import '../data/models/fuel_entry_model.dart';
import '../service/fuel_entry_service.dart';

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

  @override
  void dispose() {
    _volumeController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId == null) throw Exception('No user logged in');

      final volume = double.parse(_volumeController.text);
      final cost = double.parse(_costController.text);

      final entry = FuelEntryModel(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId ?? '',
        userId: userId,
        date: DateTime.now(),
        odometer: int.parse(_odometerController.text),
        volume: volume,
        cost: cost,
        pricePerUnit: cost / volume,
        fuelType: 'Gasoline',
        isFullTank: _isFullTank,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.addFuelEntry(entry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fuel entry added')));
        context.go('/fuel');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fuel Entry'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _volumeController,
              decoration:
                  const InputDecoration(labelText: 'Volume (L)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'Required';
                final volume = double.tryParse(v!);
                if (volume == null || volume <= 0) return 'Must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration:
                  const InputDecoration(labelText: 'Cost', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'Required';
                final cost = double.tryParse(v!);
                if (cost == null || cost < 0) return 'Must be 0 or greater';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                  labelText: 'Odometer (km)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'Required';
                final odometer = int.tryParse(v!);
                if (odometer == null || odometer < 0) return 'Must be 0 or greater';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Full Tank'),
              subtitle: const Text('Required for fuel economy calculation'),
              value: _isFullTank,
              onChanged: (v) => setState(() => _isFullTank = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Fuel Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
