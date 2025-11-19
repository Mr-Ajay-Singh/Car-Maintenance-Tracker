import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/fuel_entry_model.dart';
import '../service/fuel_entry_service.dart';
import '../../../common/utils/format_helper.dart';

class FuelDetailPage extends StatefulWidget {
  final String entryId;
  const FuelDetailPage({super.key, required this.entryId});

  @override
  State<FuelDetailPage> createState() => _FuelDetailPageState();
}

class _FuelDetailPageState extends State<FuelDetailPage> {
  final _service = FuelEntryService();
  FuelEntryModel? _entry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    try {
      final entry = await _service.getEntryById(widget.entryId);
      setState(() {
        _entry = entry;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fuel Entry?'),
        content: const Text(
            'This action cannot be undone. Are you sure you want to delete this fuel record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _service.deleteFuelEntry(widget.entryId);
        if (mounted) {
          context.pop(); // Return to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_entry == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Fuel entry not found')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Fuel Details'),
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: colorScheme.error,
                onPressed: _deleteEntry,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(context, colorScheme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: FormatHelper.formatDate(_entry!.date),
            colorScheme: colorScheme,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  icon: Icons.opacity_rounded,
                  label: 'Volume',
                  value: '${_entry!.volume.toStringAsFixed(2)} L',
                  colorScheme: colorScheme,
                ),
              ),
              Expanded(
                child: _DetailRow(
                  icon: Icons.attach_money_rounded,
                  label: 'Total Cost',
                  value: '\$${_entry!.cost.toStringAsFixed(2)}',
                  colorScheme: colorScheme,
                  valueColor: colorScheme.primary,
                  isBold: true,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _DetailRow(
            icon: Icons.speed_rounded,
            label: 'Odometer',
            value: '${_entry!.odometer} km',
            colorScheme: colorScheme,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _DetailRow(
            icon: Icons.local_gas_station_rounded,
            label: 'Price per Liter',
            value: '\$${_entry!.pricePerUnit.toStringAsFixed(3)}/L',
            colorScheme: colorScheme,
          ),
          if (_entry!.isFullTank) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Full Tank Fill-up',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? colorScheme.onSurface,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
