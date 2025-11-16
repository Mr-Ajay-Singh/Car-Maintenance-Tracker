import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/dashboard_summary_model.dart';

/// FuelSummaryWidget - Card showing fuel economy summary
class FuelSummaryWidget extends StatelessWidget {
  final FuelEconomySummary summary;

  const FuelSummaryWidget({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go('/fuel'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_gas_station,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Fuel Economy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (summary.averageMpg > 0)
                _StatRow(
                  label: 'Average',
                  value: '${summary.averageMpg.toStringAsFixed(1)} km/L',
                ),
              const SizedBox(height: 8),
              _StatRow(
                label: 'Total Cost',
                value: '\$${summary.totalCost.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: 'Total Volume',
                value: '${summary.totalVolume.toStringAsFixed(1)} L',
              ),
              const SizedBox(height: 12),
              Text(
                summary.period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
