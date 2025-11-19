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
        final entries = await _service.getAllEntries(userId);
        setState(() {
          _entries = entries;
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
        _error = 'Failed to load fuel entries: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddFuel() async {
    final result = await context.push<bool>('/fuel/add');
    if (result == true) {
      _load();
    }
  }

  Future<Map<String, String>> _getFormattedData(FuelEntryModel entry) async {
    final pricePerLiter = entry.cost / entry.volume;
    return {
      'volume': await FormatHelper.formatVolume(entry.volume),
      'cost': await FormatHelper.formatCurrency(entry.cost),
      'pricePerUnit': await FormatHelper.formatPricePerUnit(pricePerLiter),
      'odometer': await FormatHelper.formatDistance(entry.odometer),
      'date': FormatHelper.formatDate(entry.date),
    };
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
              title: const Text('Fuel Tracker'),
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
            else if (_entries.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_gas_station_outlined,
                        size: 80,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Fuel Records',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first fuel entry to track consumption',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _navigateToAddFuel,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Fuel'),
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
                      final entry = _entries[index];
                      return _FuelCard(
                        entry: entry,
                        onTap: () async {
                          // Navigate to detail page (to be implemented)
                          await context.push('/fuel/${entry.id}');
                          _load();
                        },
                        getFormattedData: _getFormattedData,
                      );
                    },
                    childCount: _entries.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _entries.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddFuel,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _FuelCard extends StatelessWidget {
  final FuelEntryModel entry;
  final VoidCallback onTap;
  final Future<Map<String, String>> Function(FuelEntryModel) getFormattedData;

  const _FuelCard({
    required this.entry,
    required this.onTap,
    required this.getFormattedData,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, String>>(
      future: getFormattedData(entry),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final volume = data['volume'] ?? '${entry.volume.toStringAsFixed(2)} L';
        final cost = data['cost'] ?? '\$${entry.cost.toStringAsFixed(2)}';
        final pricePerUnit = data['pricePerUnit'] ?? '';
        final odometer = data['odometer'] ?? '${entry.odometer} km';
        final date = data['date'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.local_gas_station_rounded,
                          color: colorScheme.onSecondaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              volume,
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
                                  date,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 13,
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pricePerUnit,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        odometer,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (entry.isFullTank)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FULL TANK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
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
