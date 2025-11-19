import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/reminder_model.dart';
import '../service/reminder_service.dart';

class AddReminderPage extends StatefulWidget {
  final String? vehicleId;
  const AddReminderPage({super.key, this.vehicleId});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ReminderService();
  
  // Controllers
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _odometerController = TextEditingController();
  final _recurringDaysController = TextEditingController();
  final _recurringOdometerController = TextEditingController();
  final _monthDayController = TextEditingController();

  // State
  bool _isSubmitting = false;
  DateTime? _dueDate;
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.interval;
  final List<int> _selectedWeekdays = [];
  bool _notificationEnabled = true;
  int _notificationDaysBefore = 7;

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    _recurringDaysController.dispose();
    _recurringOdometerController.dispose();
    _monthDayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _toggleWeekday(int day) {
    setState(() {
      if (_selectedWeekdays.contains(day)) {
        _selectedWeekdays.remove(day);
      } else {
        _selectedWeekdays.add(day);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation for recurrence
    if (_isRecurring) {
      if (_recurrenceType == RecurrenceType.weekly && _selectedWeekdays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select at least one day of the week'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      if (_recurrenceType == RecurrenceType.monthly && _monthDayController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a day of the month'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) throw Exception('No user logged in');

      // Request notification permissions if enabled
      if (_notificationEnabled) {
        await _service.initializeNotifications();
      }

      final reminder = ReminderModel(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId ?? '',
        userId: userId,
        title: _titleController.text.trim(),
        type: _typeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        dueDate: _dueDate,
        dueOdometer: int.tryParse(_odometerController.text),
        isRecurring: _isRecurring,
        recurrenceType: _isRecurring ? _recurrenceType : null,
        recurrenceWeekdays: _isRecurring && _recurrenceType == RecurrenceType.weekly ? _selectedWeekdays : null,
        recurrenceMonthDay: _isRecurring && _recurrenceType == RecurrenceType.monthly ? int.tryParse(_monthDayController.text) : null,
        recurringDays: _isRecurring && _recurrenceType == RecurrenceType.interval ? int.tryParse(_recurringDaysController.text) : null,
        recurringOdometer: _isRecurring ? int.tryParse(_recurringOdometerController.text) : null,
        notificationEnabled: _notificationEnabled,
        notificationDaysBefore: _notificationDaysBefore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.addReminder(reminder);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder scheduled successfully'), behavior: SnackBarBehavior.floating));
        context.pop(true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
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
        title: const Text('New Reminder'),
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
              'What needs to be done?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Basic Info Card
            _buildSectionCard(
              context,
              title: 'Details',
              icon: Icons.edit_note,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Oil Change',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    hintText: 'e.g., Service, Insurance',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.description_rounded),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Schedule Card
            _buildSectionCard(
              context,
              title: 'Schedule',
              icon: Icons.calendar_today_rounded,
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_rounded, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _dueDate != null 
                                  ? DateFormat.yMMMd().format(_dueDate!) 
                                  : 'Select Date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _dueDate != null ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Due Odometer (Optional)',
                    suffixText: 'km',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.speed_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notification'),
                  subtitle: const Text('Get notified when due'),
                  value: _notificationEnabled,
                  onChanged: (val) => setState(() => _notificationEnabled = val),
                  activeThumbColor: colorScheme.primary,
                ),
                if (_notificationEnabled) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _notificationDaysBefore,
                    decoration: InputDecoration(
                      labelText: 'Remind me',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.notifications_active_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('On due date')),
                      DropdownMenuItem(value: 1, child: Text('1 day before')),
                      DropdownMenuItem(value: 3, child: Text('3 days before')),
                      DropdownMenuItem(value: 7, child: Text('1 week before')),
                      DropdownMenuItem(value: 14, child: Text('2 weeks before')),
                      DropdownMenuItem(value: 30, child: Text('1 month before')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _notificationDaysBefore = val);
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Recurrence Card
            _buildSectionCard(
              context,
              title: 'Recurrence',
              icon: Icons.update_rounded,
              trailing: Switch(
                value: _isRecurring,
                onChanged: (val) => setState(() => _isRecurring = val),
              ),
              children: [
                if (_isRecurring) ...[
                  DropdownButtonFormField<RecurrenceType>(
                    initialValue: _recurrenceType,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.repeat_rounded),
                    ),
                    items: RecurrenceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _recurrenceType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Dynamic Recurrence Options
                  if (_recurrenceType == RecurrenceType.weekly) ...[
                    const Text('Select Days:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 1; i <= 7; i++)
                          FilterChip(
                            label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i - 1]),
                            selected: _selectedWeekdays.contains(i),
                            onSelected: (_) => _toggleWeekday(i),
                            showCheckmark: false,
                            selectedColor: colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: _selectedWeekdays.contains(i) 
                                ? colorScheme.onPrimaryContainer 
                                : colorScheme.onSurface,
                              fontWeight: _selectedWeekdays.contains(i) ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedWeekdays.contains(i) 
                                  ? Colors.transparent 
                                  : colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ] else if (_recurrenceType == RecurrenceType.monthly) ...[
                    TextFormField(
                      controller: _monthDayController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Day of Month (1-31)',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.today_rounded),
                      ),
                      validator: (v) {
                        if (!_isRecurring || _recurrenceType != RecurrenceType.monthly) return null;
                        final day = int.tryParse(v ?? '');
                        if (day == null || day < 1 || day > 31) return 'Invalid day';
                        return null;
                      },
                    ),
                  ] else if (_recurrenceType == RecurrenceType.interval) ...[
                    TextFormField(
                      controller: _recurringDaysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Repeat every (days)',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.timer_rounded),
                      ),
                      validator: (v) {
                        if (!_isRecurring || _recurrenceType != RecurrenceType.interval) return null;
                        if (v?.isEmpty == true) return 'Required';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _recurringOdometerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Repeat every (km) - Optional',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.add_road_rounded),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Enable this to set up a recurring schedule for this reminder.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submit,
        icon: _isSubmitting 
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.check_rounded),
        label: Text(_isSubmitting ? 'Saving...' : 'Create Reminder'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionCard(BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
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
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}
