import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psoriasis_tracker/features/data_export/services/data_export_service.dart';
import 'package:psoriasis_tracker/features/data_export/services/file_service.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/mixpanel_utils.dart';

class DataExportPage extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final ExportDataType? initialDataType;

  const DataExportPage({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialDataType,
  }) : super(key: key);

  @override
  State<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends State<DataExportPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = false;
  bool _isPreviewLoading = false;
  bool _isPremium = false;
  String _exportFormat = 'pdf';
  late ExportDataType _selectedDataType;
  final List<ExportData> _availableDataTypes =
      DataExportService.getAvailableExportTypes();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ??
        DateTime.now().subtract(const Duration(days: 30));
    _endDate = widget.initialEndDate ?? DateTime.now();
    _selectedDataType = widget.initialDataType ?? ExportDataType.fiber;
    _checkPremiumStatus();
    MixpanelUtils.trackEventForOpen('data_export_page_opened');
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = true;// await PremiumService.isPurchasedSubStatus();
    setState(() {
      _isPremium = isPremium;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Ensure start date is not after end date
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _exportData() async {
    // Check if user is premium
    MixpanelUtils.trackEventForClick('data_export', 'export_data_button_tapped_${_exportFormat}');
    if (!_isPremium) {
      // Redirect to premium page
      Navigator.pushNamed(context, '/premium');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get data for the selected type and date range
      final data = await _getDataForExport();

      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.noDataForDateRange)),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Export based on selected format
      File exportedFile;
      if (_exportFormat == 'pdf') {
        exportedFile = await DataExportService.exportToPdf(
          dataType: _selectedDataType,
          startDate: _startDate,
          endDate: _endDate,
          data: data,
        );
      } else {
        exportedFile = await DataExportService.exportToCsv(
          dataType: _selectedDataType,
          data: data,
        );
      }

      if (mounted) {
        // Directly share the file without showing a dialog
        final fileName = exportedFile.path.split('/').last;
        await FileService.shareFile(context, exportedFile, fileName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${AppLocalizations.of(context)!.dataExportedSuccess} ${_exportFormat.toUpperCase()}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${AppLocalizations.of(context)!.errorExportingData}: ${e.toString()}")),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _previewData() async {
    MixpanelUtils.trackEventForClick('data_export', 'preview_data_button_tapped_${_exportFormat}');
    setState(() {
      _isPreviewLoading = true;
    });

    try {
      // Get data for preview (either real data or dummy data)
      final data = await _getDataForPreview();

      if (data.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.noDataForPreview)),
          );
        }
        setState(() {
          _isPreviewLoading = false;
        });
        return;
      }

      // Generate preview file
      File previewFile;
      if (_exportFormat == 'pdf') {
        previewFile = await DataExportService.exportToPdf(
          dataType: _selectedDataType,
          startDate: _startDate,
          endDate: _endDate,
          data: data,
        );
      } else {
        previewFile = await DataExportService.exportToCsv(
          dataType: _selectedDataType,
          data: data,
        );
      }

      if (mounted) {
        // Show preview dialog
        final fileName = previewFile.path.split('/').last;
        await FileService.showPreviewDialog(
            context, previewFile, fileName, _isPremium);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "${AppLocalizations.of(context)!.errorGeneratingPreview}: ${e.toString()}")),
        );
      }
    } finally {
      setState(() {
        _isPreviewLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getDataForExport() async {
    switch (_selectedDataType) {
      // case ExportDataType.protein:
      //   return await DataExportService.getProteinData(_startDate, _endDate);
      // case ExportDataType.water:
      //   return await DataExportService.getWaterData(_startDate, _endDate);
      // case ExportDataType.weight:
      //   return await DataExportService.getWeightData(_startDate, _endDate);
      // case ExportDataType.fiber:
      //   return await DataExportService.getFiberData(_startDate, _endDate);
      case ExportDataType.water:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ExportDataType.weight:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ExportDataType.protein:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ExportDataType.fiber:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Future<List<Map<String, dynamic>>> _getDataForPreview() async {
    // If user is premium, use real data
    if (_isPremium) {
      return _getDataForExport();
    }

    // Otherwise use dummy data
    switch (_selectedDataType) {
      case ExportDataType.protein:
        return DataExportService.getDummyProteinData(_startDate, _endDate);
      case ExportDataType.water:
        return DataExportService.getDummyWaterData(_startDate, _endDate);
      case ExportDataType.weight:
        return DataExportService.getDummyWeightData(_startDate, _endDate);
      case ExportDataType.fiber:
        // Use protein dummy data for fiber preview
        return DataExportService.getDummyProteinData(_startDate, _endDate).map((item) {
          return {
            'date': item['date'],
            'item': item['item'],
            'fiber': item['protein'],
          };
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: theme.surfaceDim,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.exportData,
          style: TextStyle(
            color: theme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectDataType,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildDataTypeSegmentedButton(context),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.selectDateRange,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    context,
                    AppLocalizations.of(context)!.startDate,
                    _startDate,
                    () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    context,
                    AppLocalizations.of(context)!.endDate,
                    _endDate,
                    () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.exportFormat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFormatOption(
                  context,
                  AppLocalizations.of(context)!.pdfFormat,
                  AppLocalizations.of(context)!.pdfDescription,
                  Icons.picture_as_pdf_rounded,
                  _exportFormat == 'pdf',
                  () => setState(() => _exportFormat = 'pdf'),
                ),
                const SizedBox(width: 16),
                _buildFormatOption(
                  context,
                  AppLocalizations.of(context)!.csvFormat,
                  AppLocalizations.of(context)!.csvDescription,
                  Icons.table_chart_rounded,
                  _exportFormat == 'csv',
                  () => setState(() => _exportFormat = 'csv'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.surfaceDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _exportFormat == 'pdf'
                            ? Icons.picture_as_pdf_rounded
                            : Icons.table_chart_rounded,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.exportPreview,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${AppLocalizations.of(context)!.dataTypeLabel} ${_getDataTypeDisplayName()}",
                    style: TextStyle(
                      color: theme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${AppLocalizations.of(context)!.dateRangeLabel} ${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}",
                    style: TextStyle(
                      color: theme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${AppLocalizations.of(context)!.formatLabel} ${_exportFormat.toUpperCase()}",
                    style: TextStyle(
                      color: theme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Preview button - only show for non-premium users
            if (!_isPremium) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPreviewLoading ? null : _previewData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondary,
                    foregroundColor: theme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPreviewLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme.onSecondary),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.previewData,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Export button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _exportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.onPrimary),
                        ),
                      )
                    : Text(
                        _isPremium
                            ? AppLocalizations.of(context)!.shareData
                            : AppLocalizations.of(context)!.getPremiumToExport,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeSegmentedButton(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surfaceDim,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: _availableDataTypes.map((dataType) {
            final isSelected = dataType.type == _selectedDataType;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedDataType = dataType.type);
                  MixpanelUtils.trackEventForClick('data_export', 'data_type_tapped_${dataType.type}');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        dataType.icon,
                        color: isSelected ? theme.onPrimary : theme.onSurface,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dataType.title.split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.onPrimary : theme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getDataTypeDisplayName() {
    switch (_selectedDataType) {
      case ExportDataType.protein:
        return AppLocalizations.of(context)!.proteinData;
      case ExportDataType.water:
        return AppLocalizations.of(context)!.waterData;
      case ExportDataType.weight:
        return AppLocalizations.of(context)!.weightData;
      case ExportDataType.fiber:
        return 'Fiber Data';
    }
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surfaceDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: theme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surfaceDim,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? theme.primary : theme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primary.withOpacity(0.2)
                          : theme.surfaceVariant.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? theme.primary : theme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? theme.primary : theme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
