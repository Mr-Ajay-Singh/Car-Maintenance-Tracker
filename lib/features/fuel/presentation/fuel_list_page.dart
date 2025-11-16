import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/fuel_entry_model.dart';
import '../service/fuel_entry_service.dart';
import '../../../common/utils/format_helper.dart';

class FuelListPage extends StatefulWidget {
  const FuelListPage({super.key});

  @override
  State<FuelListPage> createState() => _FuelListPageState();
}

class _FuelListPageState extends State<FuelListPage> {
  final _service = FuelEntryService();
  List<FuelEntryModel> _entries = [];
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
        final entries = await _service.getAllEntries(userId);
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, String>> _getFormattedData(FuelEntryModel entry) async {
    final pricePerLiter = entry.cost / entry.volume;
    return {
      'volume': await FormatHelper.formatVolume(entry.volume),
      'cost': await FormatHelper.formatCurrency(entry.cost),
      'pricePerUnit': await FormatHelper.formatPricePerUnit(pricePerLiter),
      'odometer': await FormatHelper.formatDistance(entry.odometer),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Tracker'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_gas_station_outlined,
                          size: 120, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 24),
                      const Text('No fuel records yet'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];

                      return FutureBuilder<Map<String, String>>(
                        future: _getFormattedData(entry),
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? {};
                          final volume = data['volume'] ?? '${entry.volume.toStringAsFixed(2)} L';
                          final cost = data['cost'] ?? '\$${entry.cost.toStringAsFixed(2)}';
                          final pricePerUnit = data['pricePerUnit'] ?? '\$${(entry.cost / entry.volume).toStringAsFixed(2)}/L';
                          final odometer = data['odometer'] ?? '${entry.odometer} km';

                          return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Future: Navigate to fuel entry detail
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.local_gas_station,
                                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            volume,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                                FormatHelper.formatDate(entry.date),
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          cost,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pricePerUnit,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.speed,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Odometer: $odometer',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const Spacer(),
                                      if (entry.isFullTank)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.tertiaryContainer,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'FULL',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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
        onPressed: () => context.go('/fuel/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Fuel'),
      ),
    );
  }
}
