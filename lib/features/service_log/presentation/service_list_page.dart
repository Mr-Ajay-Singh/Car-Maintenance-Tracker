import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';
import '../data/models/service_entry_model.dart';
import '../service/service_entry_service.dart';

import '../../../common/utils/format_helper.dart';
/// ServiceListPage - List of all service entries
class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  final ServiceEntryService _service = ServiceEntryService();
  List<ServiceEntryModel> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
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

  Future<Map<String, String>> _getFormattedData(ServiceEntryModel entry) async {
    return {
      'cost': await FormatHelper.formatCurrency(entry.totalCost),
      'odometer': await FormatHelper.formatDistance(entry.odometer),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];

                      return FutureBuilder<Map<String, String>>(
                        future: _getFormattedData(entry),
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? {};
                          final cost = data['cost'] ?? '\$${entry.totalCost.toStringAsFixed(2)}';
                          final odometer = data['odometer'] ?? '${entry.odometer} km';

                          return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.go('/service/${entry.id}'),
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
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.build,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.serviceType,
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
                                    Text(
                                      cost,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
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
                                      if (entry.serviceProvider != null && entry.serviceProvider!.isNotEmpty) ...[
                                        const SizedBox(width: 16),
                                        const Text('•'),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry.serviceProvider!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.notes!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
        onPressed: () => context.go('/service/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_outlined,
              size: 120, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('No Service Records',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first service record'),
        ],
      ),
    );
  }
}
