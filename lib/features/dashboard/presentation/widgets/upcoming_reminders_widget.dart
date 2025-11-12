import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/dashboard_summary_model.dart';

/// UpcomingRemindersWidget - List of upcoming reminders
class UpcomingRemindersWidget extends StatelessWidget {
  final List<UpcomingReminder> reminders;

  const UpcomingRemindersWidget({
    super.key,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: reminders.map((reminder) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => context.go('/reminders/${reminder.id}'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reminder.isOverdue
                        ? Theme.of(context).colorScheme.errorContainer
                        : reminder.isDueSoon
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(reminder.type),
                        color: reminder.isOverdue
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : reminder.isDueSoon
                                ? Theme.of(context).colorScheme.onTertiaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _getDueText(reminder),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (reminder.isOverdue)
                        Chip(
                          label: const Text('Overdue'),
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'service':
      case 'maintenance':
        return Icons.build;
      case 'insurance':
        return Icons.policy;
      case 'registration':
        return Icons.assignment;
      case 'inspection':
        return Icons.fact_check;
      default:
        return Icons.notification_important;
    }
  }

  String _getDueText(UpcomingReminder reminder) {
    if (reminder.isOverdue) {
      if (reminder.daysRemaining != null) {
        return '${reminder.daysRemaining!.abs()} days overdue';
      }
      return 'Overdue';
    }

    final parts = <String>[];
    if (reminder.daysRemaining != null) {
      if (reminder.daysRemaining == 0) {
        parts.add('Due today');
      } else if (reminder.daysRemaining == 1) {
        parts.add('Due tomorrow');
      } else {
        parts.add('Due in ${reminder.daysRemaining} days');
      }
    }

    if (reminder.odometerRemaining != null && reminder.odometerRemaining! > 0) {
      parts.add('${reminder.odometerRemaining} km remaining');
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'Upcoming';
  }
}
