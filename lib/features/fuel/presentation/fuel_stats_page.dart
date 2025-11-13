import 'package:flutter/material.dart';

class FuelStatsPage extends StatelessWidget {
  final String? vehicleId;
  const FuelStatsPage({super.key, this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: const Center(child: Text('Fuel Statistics - Coming Soon')),
    );
  }
}
