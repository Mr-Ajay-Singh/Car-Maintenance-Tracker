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
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: reminder.isOverdue ? 4 : 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: reminder.isOverdue
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                  width: 2,
                                )
                              : BorderSide.none,
                        ),
                        color: reminder.isOverdue
                            ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.3)
                            : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/reminders/${reminder.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: reminder.isOverdue
                                        ? Theme.of(context).colorScheme.error
                                        : reminder.isCompleted
                                            ? Colors.green
                                            : Theme.of(context).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    reminder.isCompleted
                                        ? Icons.check_circle
                                        : reminder.isOverdue
                                            ? Icons.warning
                                            : Icons.notifications,
                                    color: reminder.isOverdue
                                        ? Theme.of(context).colorScheme.onError
                                        : reminder.isCompleted
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.onTertiaryContainer,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              reminder.title,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    decoration: reminder.isCompleted
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                  ),
                                            ),
                                          ),
                                          if (reminder.isOverdue && !reminder.isCompleted)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.error,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'OVERDUE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.onError,
                                                ),
                                              ),
                                            ),
                                          if (reminder.isCompleted)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'DONE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reminder.type,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      if (reminder.dueDate != null) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Due: ${reminder.dueDate!.day}/${reminder.dueDate!.month}/${reminder.dueDate!.year}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: reminder.isOverdue
                                                        ? Theme.of(context).colorScheme.error
                                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                                    fontWeight: reminder.isOverdue ? FontWeight.bold : null,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
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
