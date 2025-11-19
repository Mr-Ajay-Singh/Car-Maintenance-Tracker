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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
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
        _error = 'Failed to load services: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddService() async {
    final result = await context.push<bool>('/service/add');
    if (result == true) {
      _loadEntries();
    }
  }

  Future<Map<String, String>> _getFormattedData(ServiceEntryModel entry) async {
    return {
      'cost': await FormatHelper.formatCurrency(entry.totalCost),
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
        onRefresh: _loadEntries,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              floating: true,
              pinned: false,
              centerTitle: true,
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
                        onPressed: _loadEntries,
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
                        Icons.build_circle_outlined,
                        size: 80,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Service Records',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first service record to track maintenance',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _navigateToAddService,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Service'),
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
                      return _ServiceCard(
                        entry: entry,
                        onTap: () async {
                          await context.push('/service/${entry.id}');
                          _loadEntries();
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
              onPressed: _navigateToAddService,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceEntryModel entry;
  final VoidCallback onTap;
  final Future<Map<String, String>> Function(ServiceEntryModel) getFormattedData;

  const _ServiceCard({
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
        final cost = data['cost'] ?? '\$${entry.totalCost.toStringAsFixed(2)}';
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
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.build_rounded,
                          color: colorScheme.onPrimaryContainer,
                          size: 24,
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
                      Text(
                        cost,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
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
                      if (entry.shopName != null && entry.shopName!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            entry.shopName!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
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
