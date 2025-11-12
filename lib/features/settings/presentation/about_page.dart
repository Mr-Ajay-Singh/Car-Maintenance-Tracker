import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('CarLog: Maintenance Tracker',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 24),
            const Text('Track maintenance, fuel, and expenses',
                textAlign: TextAlign.center),
            const Text('for all your vehicles in one app',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
