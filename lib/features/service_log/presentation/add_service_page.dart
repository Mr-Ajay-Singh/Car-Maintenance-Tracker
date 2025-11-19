import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/service_entry_model.dart';
import '../service/service_entry_service.dart';

class AddServicePage extends StatefulWidget {
  final String? vehicleId;
  const AddServicePage({super.key, this.vehicleId});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ServiceEntryService();
  
  final _serviceTypeController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _odometerController.dispose();
    _costController.dispose();
    _shopNameController.dispose();
    _notesController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) throw Exception('No user logged in');

      final entry = ServiceEntryModel(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId ?? '', // Note: This might need to be selected if not passed
        userId: userId,
        date: _selectedDate,
        odometer: int.parse(_odometerController.text.trim()),
        serviceType: _serviceTypeController.text.trim(),
        totalCost: double.parse(_costController.text.trim()),
        shopName: _shopNameController.text.trim().isEmpty ? null : _shopNameController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.addServiceEntry(entry);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully'),
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
        title: const Text('Add Service'),
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
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 24),

            // Basic Info Card
            _buildSectionCard(
              context,
              title: 'Service Info',
              icon: Icons.build_circle_rounded,
              children: [
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    hintText: 'e.g., Oil Change, Tire Rotation',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.miscellaneous_services_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
              ],
            ),
            const SizedBox(height: 24),

            // Details Card
            _buildSectionCard(
              context,
              title: 'Details',
              icon: Icons.receipt_long_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _odometerController,
                        decoration: InputDecoration(
                          labelText: 'Odometer',
                          suffixText: 'km',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.speed_rounded),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.trim().isEmpty == true) return 'Required';
                          final val = int.tryParse(v!.trim());
                          if (val == null || val < 0) return 'Invalid';
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
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shopNameController,
                  decoration: InputDecoration(
                    labelText: 'Shop Name (Optional)',
                    hintText: 'e.g., Jiffy Lube',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.store_rounded),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Notes Card
            _buildSectionCard(
              context,
              title: 'Notes',
              icon: Icons.note_alt_rounded,
              children: [
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.description_rounded),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
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
        label: Text(_isSubmitting ? 'Saving...' : 'Save Service'),
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
