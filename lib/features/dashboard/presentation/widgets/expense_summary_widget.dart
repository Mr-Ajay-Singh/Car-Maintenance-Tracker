import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/dashboard_summary_model.dart';

/// ExpenseSummaryWidget - Card showing expense summary
class ExpenseSummaryWidget extends StatelessWidget {
  final ExpenseSummary summary;
  final VoidCallback? onReturn;

  const ExpenseSummaryWidget({
    super.key,
    required this.summary,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () async {
          await context.push('/expenses');
          onReturn?.call();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '\$${summary.totalExpenses.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              _ExpenseBar(
                label: 'Service',
                amount: summary.serviceExpenses,
                total: summary.totalExpenses,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              _ExpenseBar(
                label: 'Fuel',
                amount: summary.fuelExpenses,
                total: summary.totalExpenses,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              _ExpenseBar(
                label: 'Other',
                amount: summary.otherExpenses,
                total: summary.totalExpenses,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 16),
              Text(
                summary.period,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

class _ExpenseBar extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  final Color color;

  const _ExpenseBar({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
