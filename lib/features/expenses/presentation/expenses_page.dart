import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/expense_model.dart';
import '../service/expense_service.dart';

import '../../../common/utils/format_helper.dart';
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

// Helper function to get category-specific icon
IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'Insurance':
      return Icons.shield;
    case 'Registration':
      return Icons.description;
    case 'Parking':
      return Icons.local_parking;
    case 'Fine/Ticket':
      return Icons.warning;
    case 'Parts':
      return Icons.build_circle;
    case 'Tolls':
      return Icons.toll;
    case 'Cleaning/Detailing':
      return Icons.local_car_wash;
    case 'Storage':
      return Icons.garage;
    default:
      return Icons.receipt;
  }
}

// Helper function to get category color
Color _getCategoryColor(BuildContext context, String category) {
  switch (category) {
    case 'Insurance':
      return Theme.of(context).colorScheme.primary;
    case 'Registration':
      return Theme.of(context).colorScheme.secondary;
    case 'Parking':
      return Theme.of(context).colorScheme.tertiary;
    case 'Fine/Ticket':
      return Theme.of(context).colorScheme.error;
    case 'Parts':
      return Theme.of(context).colorScheme.primaryContainer;
    case 'Tolls':
      return Theme.of(context).colorScheme.secondaryContainer;
    case 'Cleaning/Detailing':
      return Theme.of(context).colorScheme.tertiaryContainer;
    case 'Storage':
      return Theme.of(context).colorScheme.surfaceVariant;
    default:
      return Theme.of(context).colorScheme.surfaceVariant;
  }
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _service = ExpenseService();
  List<ExpenseModel> _expenses = [];
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
        final expenses = await _service.getAllExpenses(userId);
        setState(() {
          _expenses = expenses;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getFormattedAmount(double amount) async {
    return await FormatHelper.formatCurrency(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 120, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      const Text('No expenses yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      final categoryColor = _getCategoryColor(context, expense.category);
                      final categoryIcon = _getCategoryIcon(expense.category);

                      return FutureBuilder<String>(
                        future: _getFormattedAmount(expense.amount),
                        builder: (context, snapshot) {
                          final amount = snapshot.data ?? '\$${expense.amount.toStringAsFixed(2)}';

                          return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Future: Navigate to expense detail
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    categoryIcon,
                                    color: categoryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.category,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            FormatHelper.formatDate(expense.date),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                      if (expense.description != null && expense.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          expense.description!,
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      amount,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (expense.isRecurring) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.repeat,
                                              size: 12,
                                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              expense.recurringPeriod ?? 'Recurring',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/expenses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
