import 'package:flutter/material.dart';
import '../../../common/data/shared_preferences_helper.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String _currency = 'USD';
  String _volumeUnit = 'L';
  String _distanceUnit = 'km';
  bool _isLoading = true;

  // Currency options
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
  ];

  // Volume unit options
  final List<Map<String, String>> _volumeUnits = [
    {'code': 'L', 'name': 'Liters'},
    {'code': 'gal', 'name': 'Gallons (US)'},
    {'code': 'gal_uk', 'name': 'Gallons (UK)'},
  ];

  // Distance unit options
  final List<Map<String, String>> _distanceUnits = [
    {'code': 'km', 'name': 'Kilometers'},
    {'code': 'mi', 'name': 'Miles'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final currency = await SharedPreferencesHelper.getCurrency();
    final volumeUnit = await SharedPreferencesHelper.getVolumeUnit();
    final distanceUnit = await SharedPreferencesHelper.getDistanceUnit();

    setState(() {
      _currency = currency;
      _volumeUnit = volumeUnit;
      _distanceUnit = distanceUnit;
      _isLoading = false;
    });
  }

  Future<void> _updateCurrency(String currency) async {
    await SharedPreferencesHelper.setCurrency(currency);
    setState(() => _currency = currency);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Currency updated to ${_getCurrencyName(currency)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateVolumeUnit(String unit) async {
    await SharedPreferencesHelper.setVolumeUnit(unit);
    setState(() => _volumeUnit = unit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Volume unit updated to ${_getVolumeUnitName(unit)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateDistanceUnit(String unit) async {
    await SharedPreferencesHelper.setDistanceUnit(unit);
    setState(() => _distanceUnit = unit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Distance unit updated to ${_getDistanceUnitName(unit)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getCurrencyName(String code) {
    return _currencies.firstWhere((c) => c['code'] == code, orElse: () => {'name': code})['name']!;
  }

  String _getVolumeUnitName(String code) {
    return _volumeUnits.firstWhere((u) => u['code'] == code, orElse: () => {'name': code})['name']!;
  }

  String _getDistanceUnitName(String code) {
    return _distanceUnits.firstWhere((u) => u['code'] == code, orElse: () => {'name': code})['name']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Currency Section
                Text(
                  'Currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: _currencies.map((currency) {
                      final isSelected = _currency == currency['code'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text(
                            currency['symbol']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(currency['name']!),
                        subtitle: Text(currency['code']!),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => _updateCurrency(currency['code']!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Volume Unit Section
                Text(
                  'Volume Unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: _volumeUnits.map((unit) {
                      final isSelected = _volumeUnit == unit['code'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.local_gas_station,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(unit['name']!),
                        subtitle: Text(unit['code']!),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary)
                            : null,
                        onTap: () => _updateVolumeUnit(unit['code']!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Distance Unit Section
                Text(
                  'Distance Unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  child: Column(
                    children: _distanceUnits.map((unit) {
                      final isSelected = _distanceUnit == unit['code'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.speed,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(unit['name']!),
                        subtitle: Text(unit['code']!),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary)
                            : null,
                        onTap: () => _updateDistanceUnit(unit['code']!),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
