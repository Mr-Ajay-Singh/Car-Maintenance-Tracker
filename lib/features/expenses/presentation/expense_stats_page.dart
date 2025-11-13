import 'package:flutter/material.dart';

class ExpenseStatsPage extends StatelessWidget {
  final String? vehicleId;
  const ExpenseStatsPage({super.key, this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const Center(child: Text('Expense Statistics - Coming Soon')),
    );
  }
}
