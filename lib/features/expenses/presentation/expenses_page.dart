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

class _ExpensesPageState extends State<ExpensesPage> {
  final _service = ExpenseService();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        final expenses = await _service.getAllExpenses(userId);
        setState(() {
          _expenses = expenses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No user logged in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load expenses: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddExpense() async {
    final result = await context.push<bool>('/expenses/add');
    if (result == true) {
      _load();
    }
  }

  // Helper function to get category-specific icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Insurance':
        return Icons.shield_rounded;
      case 'Registration':
        return Icons.description_rounded;
      case 'Parking':
        return Icons.local_parking_rounded;
      case 'Fine/Ticket':
        return Icons.warning_rounded;
      case 'Parts':
        return Icons.build_circle_rounded;
      case 'Tolls':
        return Icons.toll_rounded;
      case 'Cleaning/Detailing':
        return Icons.local_car_wash_rounded;
      case 'Storage':
        return Icons.garage_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  // Helper function to get category color
  Color _getCategoryColor(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (category) {
      case 'Insurance':
        return colorScheme.primary;
      case 'Registration':
        return colorScheme.secondary;
      case 'Parking':
        return colorScheme.tertiary;
      case 'Fine/Ticket':
        return colorScheme.error;
      case 'Parts':
        return Colors.orange;
      case 'Tolls':
        return Colors.purple;
      case 'Cleaning/Detailing':
        return Colors.teal;
      case 'Storage':
        return Colors.brown;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Expenses'),
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              floating: true,
              pinned: true,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_expenses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 80,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Expenses Recorded',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your vehicle expenses here',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _navigateToAddExpense,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = _expenses[index];
                      return _ExpenseCard(
                        expense: expense,
                        categoryIcon: _getCategoryIcon(expense.category),
                        categoryColor: _getCategoryColor(context, expense.category),
                        onTap: () async {
                          await context.push('/expenses/${expense.id}');
                          _load();
                        },
                      );
                    },
                    childCount: _expenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _expenses.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddExpense,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final IconData categoryIcon;
  final Color categoryColor;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.expense,
    required this.categoryIcon,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String>(
      future: FormatHelper.formatCurrency(expense.amount),
      builder: (context, snapshot) {
        final amount = snapshot.data ?? '\$${expense.amount.toStringAsFixed(2)}';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: categoryColor,
                      size: 24,
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
                                color: colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              FormatHelper.formatDate(expense.date),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (expense.description != null && expense.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            expense.description!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      if (expense.isRecurring) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.repeat_rounded,
                                size: 12,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                expense.recurringPeriod ?? 'Recurring',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
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
  }
}
