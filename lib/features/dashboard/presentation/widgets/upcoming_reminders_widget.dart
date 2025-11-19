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
    return Column(
      children: reminders.map((reminder) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go('/reminders/${reminder.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: reminder.isOverdue
                      ? Theme.of(context).colorScheme.error.withOpacity(0.5)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: reminder.isOverdue
                          ? Theme.of(context).colorScheme.errorContainer
                          : reminder.isDueSoon
                              ? Theme.of(context).colorScheme.tertiaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(reminder.type),
                      color: reminder.isOverdue
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : reminder.isDueSoon
                              ? Theme.of(context).colorScheme.onTertiaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDueText(reminder),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: reminder.isOverdue
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontWeight: reminder.isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
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
      }).toList(),
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
