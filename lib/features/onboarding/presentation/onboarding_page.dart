import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../common/data/shared_preferences_helper.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Welcome to CarLog',
      description: 'Your personal assistant for tracking car maintenance, fuel, and expenses.',
      icon: Icons.directions_car_filled,
    ),
    OnboardingItem(
      title: 'Track Your Vehicles',
      description: 'Manage multiple vehicles in one place. Keep track of VIN, license plate, and more.',
      icon: Icons.garage,
    ),
    OnboardingItem(
      title: 'Log Service History',
      description: 'Keep a detailed record of all maintenance and repairs. Never lose a receipt again.',
      icon: Icons.build,
    ),
    OnboardingItem(
      title: 'Monitor Fuel Economy',
      description: 'Track your MPG and fuel costs over time. Identify trends and save money.',
      icon: Icons.local_gas_station,
    ),
    OnboardingItem(
      title: 'Manage Expenses',
      description: 'Track insurance, registration, parking, and other vehicle-related costs.',
      icon: Icons.receipt_long,
    ),
    OnboardingItem(
      title: 'Sync & Backup',
      description: 'Your data is safe in the cloud. Sign in to sync across devices and never lose your data.',
      icon: Icons.cloud_sync,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await SharedPreferencesHelper.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildPage(context, _items[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button (hidden on last page)
                      if (_currentPage < _items.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text('Skip'),
                        )
                      else
                        const SizedBox(width: 64), // Spacer

                      // Next/Get Started button
                      if (_currentPage < _items.length - 1)
                        FilledButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Next'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _completeOnboarding,
                          icon: const Icon(Icons.rocket_launch),
                          label: const Text('Get Started'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingItem item) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 80,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
