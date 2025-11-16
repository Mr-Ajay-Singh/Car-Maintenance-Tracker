import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/reminder_model.dart';
import '../service/reminder_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final _service = ReminderService();
  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        final reminders = await _service.getAllReminders(userId);
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_outlined,
                          size: 120, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      const Text('No reminders yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: reminder.isOverdue
                            ? Theme.of(context).colorScheme.errorContainer
                            : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: reminder.isOverdue
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.tertiaryContainer,
                            child: Icon(Icons.notifications,
                                color: reminder.isOverdue
                                    ? Theme.of(context).colorScheme.onError
                                    : Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer),
                          ),
                          title: Text(reminder.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(reminder.type),
                          trailing: reminder.isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () => context.go('/reminders/${reminder.id}'),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/reminders/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }
}
