import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/models/reminder_model.dart';
import '../service/reminder_service.dart';

class ReminderDetailPage extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderDetailPage({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isOverdue = reminder.dueDate != null && reminder.dueDate!.isBefore(DateTime.now());
    final isDueSoon = reminder.dueDate != null && !isOverdue &&
        reminder.dueDate!.difference(DateTime.now()).inDays <= 7;

    Color statusColor = colorScheme.primary;
    String statusText = 'Upcoming';
    IconData statusIcon = Icons.event;

    if (isOverdue) {
      statusColor = colorScheme.error;
      statusText = 'Overdue';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isDueSoon) {
      statusColor = colorScheme.tertiary;
      statusText = 'Due Soon';
      statusIcon = Icons.access_time;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reminder Details'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withValues(alpha: 0.1),
                    statusColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      size: 48,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    reminder.title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Details Section
            Text(
              'Details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Due Date',
                    value: reminder.dueDate != null 
                        ? DateFormat('MMMM dd, yyyy').format(reminder.dueDate!)
                        : 'Not set',
                    iconColor: Colors.blue,
                  ),
                  _buildDivider(context),
                  if (reminder.dueOdometer != null) ...[
                    _buildDetailRow(
                      context,
                      icon: Icons.speed,
                      label: 'Due Odometer',
                      value: '${NumberFormat('#,###').format(reminder.dueOdometer)} km',
                      iconColor: Colors.orange,
                    ),
                    _buildDivider(context),
                  ],
                  _buildDetailRow(
                    context,
                    icon: Icons.update,
                    label: 'Recurrence',
                    value: reminder.isRecurring
                        ? _formatRecurrence(reminder)
                        : 'One-time',
                    iconColor: Colors.purple,
                  ),
                  _buildDivider(context),
                  _buildDetailRow(
                    context,
                    icon: Icons.notifications_active_outlined,
                    label: 'Notification',
                    value: reminder.notificationEnabled
                        ? 'Enabled (${_getNotificationTimingText(reminder.notificationDaysBefore)})'
                        : 'Disabled',
                    iconColor: Colors.green,
                  ),
                ],
              ),
            ),

            if (reminder.description != null && reminder.description!.isNotEmpty) ...[ 
              const SizedBox(height: 32),
              Text(
                'Notes',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  reminder.description!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 0,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }

  String _formatRecurrence(ReminderModel reminder) {
    if (!reminder.isRecurring) return 'None';
    if (reminder.recurrenceType == null) return 'Recurring';
    
    switch (reminder.recurrenceType!) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.interval:
        return 'Every ${reminder.recurringDays ?? '?'} days';
    }
  }

  String _getNotificationTimingText(int days) {
    if (days == 0) return 'On due date';
    if (days == 1) return '1 day before';
    if (days == 7) return '1 week before';
    if (days == 14) return '2 weeks before';
    if (days == 30) return '1 month before';
    return '$days days before';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ReminderService>().deleteReminder(reminder.id);
        if (context.mounted) {
          context.pop(); // Return to list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting reminder: $e')),
          );
        }
      }
    }
  }
}
