import 'package:flutter/material.dart';
import '../data/models/reminder_model.dart';
import '../service/reminder_service.dart';

class ReminderDetailPage extends StatefulWidget {
  final String reminderId;
  const ReminderDetailPage({super.key, required this.reminderId});

  @override
  State<ReminderDetailPage> createState() => _ReminderDetailPageState();
}

class _ReminderDetailPageState extends State<ReminderDetailPage> {
  final _service = ReminderService();
  ReminderModel? _reminder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reminder = await _service.getReminderById(widget.reminderId);
      setState(() {
        _reminder = reminder;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminder == null
              ? const Center(child: Text('Reminder not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_reminder!.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Type: ${_reminder!.type}'),
                            if (_reminder!.description != null)
                              Text('Description: ${_reminder!.description}'),
                            if (_reminder!.isCompleted)
                              const Chip(label: Text('Completed')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
