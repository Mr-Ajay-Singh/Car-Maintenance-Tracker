import 'package:flutter/material.dart';
import '../../data/models/dashboard_summary_model.dart';

/// RecentActivityWidget - List of recent activities
class RecentActivityWidget extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivityWidget({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColor(context, activity.type),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(activity.type),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      activity.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (activity.amount != null)
                Text(
                  '\$${activity.amount!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'service':
        return Icons.build;
      case 'fuel':
        return Icons.local_gas_station;
      case 'expense':
        return Icons.receipt;
      default:
        return Icons.circle;
    }
  }

  Color _getColor(BuildContext context, String type) {
    switch (type) {
      case 'service':
        return Theme.of(context).colorScheme.primaryContainer;
      case 'fuel':
        return Theme.of(context).colorScheme.secondaryContainer;
      case 'expense':
        return Theme.of(context).colorScheme.tertiaryContainer;
      default:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }
}
