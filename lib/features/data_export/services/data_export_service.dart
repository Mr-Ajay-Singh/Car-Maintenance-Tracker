import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

enum ExportDataType {
  protein,
  water,
  weight,
  fiber,
}

class ExportData {
  final String title;
  final String description;
  final IconData icon;
  final ExportDataType type;

  const ExportData({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

class DataExportService {
  // Get available export data types
  static List<ExportData> getAvailableExportTypes() {
    return [
      const ExportData(
        title: 'Fiber Data',
        description: 'Export your fiber intake records',
        icon: Icons.grass_rounded,
        type: ExportDataType.fiber,
      ),
      const ExportData(
        title: 'Water Data',
        description: 'Export your water intake records',
        icon: Icons.water_drop_rounded,
        type: ExportDataType.water,
      ),
      const ExportData(
        title: 'Weight Data',
        description: 'Export your weight tracking records',
        icon: Icons.monitor_weight_rounded,
        type: ExportDataType.weight,
      ),
    ];
  }


  // Get water data for export
  // static Future<List<Map<String, dynamic>>> getWaterData(
  //     DateTime startDate, DateTime endDate) async {
  //   final intakes = await WaterDatabase.instance.getAllIntakes();
  //
  //   // Filter by date range
  //   final filteredIntakes = intakes.where((intake) {
  //     final date = DateTime(
  //       intake.date.year,
  //       intake.date.month,
  //       intake.date.day,
  //     );
  //     final start = DateTime(
  //       startDate.year,
  //       startDate.month,
  //       startDate.day,
  //     );
  //     final end = DateTime(
  //       endDate.year,
  //       endDate.month,
  //       endDate.day,
  //       23,
  //       59,
  //       59,
  //     );
  //
  //     return date.isAtSameMomentAs(start) ||
  //         date.isAtSameMomentAs(end) ||
  //         (date.isAfter(start) && date.isBefore(end));
  //   }).toList();
  //
  //   // Sort by date (newest first)
  //   filteredIntakes.sort((a, b) => b.date.compareTo(a.date));
  //
  //   // Convert to map for export
  //   return filteredIntakes.map((intake) {
  //     return {
  //       'date': DateFormat('yyyy-MM-dd').format(intake.date),
  //       'time': DateFormat('HH:mm').format(intake.date),
  //       'type': intake.type,
  //       'amount': intake.amount,
  //       'note': intake.note,
  //     };
  //   }).toList();
  // }

  // Get weight data for export
  // static Future<List<Map<String, dynamic>>> getWeightData(
  //     DateTime startDate, DateTime endDate) async {}
  //   final logs = await WeightDatabase.instance.getAllWeightLogs();
  //
  //   // Filter by date range
  //   final filteredLogs = logs.where((log) {
  //     final date = DateTime(
  //       log.date.year,
  //       log.date.month,
  //       log.date.day,
  //     );
  //     final start = DateTime(
  //       startDate.year,
  //       startDate.month,
  //       startDate.day,
  //     );
  //     final end = DateTime(
  //       endDate.year,
  //       endDate.month,
  //       endDate.day,
  //       23,
  //       59,
  //       59,
  //     );
  //
  //     return date.isAtSameMomentAs(start) ||
  //         date.isAtSameMomentAs(end) ||
  //         (date.isAfter(start) && date.isBefore(end));
  //   }).toList();
  //
  //   // Sort by date (newest first)
  //   filteredLogs.sort((a, b) => b.date.compareTo(a.date));
  //
  //   // Convert to map for export
  //   return filteredLogs.map((log) {
  //     return {
  //       'date': DateFormat('yyyy-MM-dd').format(log.date),
  //       'weight': log.weight,
  //       'unit': log.unit,
  //     };
  //   }).toList();
  // }

  // Export data to PDF
  static Future<File> exportToPdf({
    required ExportDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> data,
  }) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Get daily totals based on data type
    final dailyTotals = _calculateDailyTotals(dataType, data);

    // For water, also calculate totals by drink type
    Map<String, Map<String, double>>? waterTotalsByType;
    if (dataType == ExportDataType.water) {
      waterTotalsByType = _calculateWaterDailyTotalsByType(data);
    }

    // Add title page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  _getReportTitle(dataType),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Date Range: ${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Total Entries: ${data.length}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total Days: ${dailyTotals.length}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (dataType != ExportDataType.weight) ...[
                  pw.SizedBox(height: 10),
                  pw.Text(
                    _getAverageText(dataType, dailyTotals),
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
                pw.SizedBox(height: 60),
                pw.Text(
                  'Generated on ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                      fontSize: 12, fontStyle: pw.FontStyle.italic),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add data page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final sortedDates = dailyTotals.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Detailed entries section
              pw.Text(
                'Detailed Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              _buildDataTable(dataType, data),

              // Daily summary section
              pw.SizedBox(height: 30),
              pw.Text(
                'Daily Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              if (dataType == ExportDataType.water && waterTotalsByType != null)
                _buildWaterSummaryTables(
                    sortedDates, dailyTotals, waterTotalsByType)
              else
                _buildSummaryTable(dataType, sortedDates, dailyTotals),
            ],
          );
        },
      ),
    );

    // If there are more than 10 entries, add additional pages
    if (data.length > 10) {
      final chunks = <List<Map<String, dynamic>>>[];
      for (var i = 10; i < data.length; i += 20) {
        chunks.add(data.skip(i).take(20).toList());
      }

      for (final chunk in chunks) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Additional Entries',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  _buildDataTable(dataType, chunk),
                ],
              );
            },
          ),
        );
      }
    }

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final fileName = _getFileName(dataType, 'pdf');
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Export data to CSV
  static Future<File> exportToCsv({
    required ExportDataType dataType,
    required List<Map<String, dynamic>> data,
  }) async {
    // Create CSV data
    final csvData = [
      _getCsvHeaders(dataType), // Header row
      ...data.map((item) => _getCsvRow(dataType, item)),
    ];

    // Convert to CSV string
    final csv = const ListToCsvConverter().convert(csvData);

    // Save the CSV file
    final output = await getTemporaryDirectory();
    final fileName = _getFileName(dataType, 'csv');
    final file = File('${output.path}/$fileName');
    await file.writeAsString(csv);

    return file;
  }

  // Helper methods
  static Map<String, double> _calculateDailyTotals(
      ExportDataType dataType, List<Map<String, dynamic>> data) {
    final Map<String, double> dailyTotals = {};

    for (final item in data) {
      final date = item['date'] as String;

      switch (dataType) {
        case ExportDataType.protein:
          final protein = item['protein'] as double;
          dailyTotals[date] = (dailyTotals[date] ?? 0.0) + protein;
          break;
        case ExportDataType.water:
          final amount = item['amount'] as int;
          dailyTotals[date] = (dailyTotals[date] ?? 0.0) + amount;
          break;
        case ExportDataType.weight:
          // For weight, we just take the latest reading for the day
          final weight = item['weight'] as double;
          dailyTotals[date] = weight;
          break;
        case ExportDataType.fiber:
          final fiber = item['fiber'] as double;
          dailyTotals[date] = (dailyTotals[date] ?? 0.0) + fiber;
          break;
      }
    }

    return dailyTotals;
  }

  // Calculate daily totals by drink type for water tracker
  static Map<String, Map<String, double>> _calculateWaterDailyTotalsByType(
      List<Map<String, dynamic>> data) {
    final Map<String, Map<String, double>> dailyTotalsByType = {};

    for (final item in data) {
      final date = item['date'] as String;
      final amount = item['amount'] as int;
      final type = item['type'] as String;

      // Initialize the map for this date if it doesn't exist
      if (!dailyTotalsByType.containsKey(date)) {
        dailyTotalsByType[date] = {
          'water': 0.0,
          'coffee': 0.0,
          'tea': 0.0,
          'juice': 0.0,
          'other': 0.0,
        };
      }

      // Add the amount to the appropriate type
      switch (type.toLowerCase()) {
        case 'water':
          dailyTotalsByType[date]!['water'] =
              (dailyTotalsByType[date]!['water'] ?? 0.0) + amount;
          break;
        case 'coffee':
          dailyTotalsByType[date]!['coffee'] =
              (dailyTotalsByType[date]!['coffee'] ?? 0.0) + amount;
          break;
        case 'tea':
          dailyTotalsByType[date]!['tea'] =
              (dailyTotalsByType[date]!['tea'] ?? 0.0) + amount;
          break;
        case 'juice':
          dailyTotalsByType[date]!['juice'] =
              (dailyTotalsByType[date]!['juice'] ?? 0.0) + amount;
          break;
        default:
          dailyTotalsByType[date]!['other'] =
              (dailyTotalsByType[date]!['other'] ?? 0.0) + amount;
          break;
      }
    }

    return dailyTotalsByType;
  }

  static String _getReportTitle(ExportDataType dataType) {
    switch (dataType) {
      case ExportDataType.protein:
        return 'Protein Tracker Report';
      case ExportDataType.water:
        return 'Water Tracker Report';
      case ExportDataType.weight:
        return 'Weight Tracker Report';
      case ExportDataType.fiber:
        return 'Fiber Tracker Report';
    }
  }

  static String _getAverageText(
      ExportDataType dataType, Map<String, double> dailyTotals) {
    if (dailyTotals.isEmpty) return 'Average: 0';

    final average =
        dailyTotals.values.reduce((a, b) => a + b) / dailyTotals.length;

    switch (dataType) {
      case ExportDataType.protein:
        return 'Average Daily Protein: ${average.toStringAsFixed(1)}g';
      case ExportDataType.water:
        return 'Average Daily Water: ${average.toStringAsFixed(0)}ml';
      case ExportDataType.weight:
        // Not applicable for weight
        return '';
      case ExportDataType.fiber:
        return 'Average Daily Fiber: ${average.toStringAsFixed(1)}g';
    }
  }

  static pw.Widget _buildDataTable(
      ExportDataType dataType, List<Map<String, dynamic>> data) {
    switch (dataType) {
      case ExportDataType.protein:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Item',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Protein (g)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows (limited to first 10 entries to fit on page)
            ...data.take(10).map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['date'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['item'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                          (item['protein'] as double).toStringAsFixed(1)),
                    ),
                  ],
                )),
          ],
        );
      case ExportDataType.water:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Time',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Type',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Amount (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Note',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows
            ...data.take(10).map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['date'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['time'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['type'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text((item['amount'] as int).toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['note'] as String),
                    ),
                  ],
                )),
          ],
        );
      case ExportDataType.weight:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Weight',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Unit',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows
            ...data.take(10).map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['date'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                          (item['weight'] as double).toStringAsFixed(1)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['unit'] as String),
                    ),
                  ],
                )),
          ],
        );
      case ExportDataType.fiber:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Item',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Fiber (g)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows (limited to first 10 entries to fit on page)
            ...data.take(10).map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['date'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item['item'] as String),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                          (item['fiber'] as double).toStringAsFixed(1)),
                    ),
                  ],
                )),
          ],
        );
    }
  }

  static pw.Widget _buildSummaryTable(ExportDataType dataType,
      List<String> sortedDates, Map<String, double> dailyTotals) {
    switch (dataType) {
      case ExportDataType.protein:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Total Protein (g)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows (limited to first 10 days to fit on page)
            ...sortedDates.take(10).map((date) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(date),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(dailyTotals[date]!.toStringAsFixed(1)),
                    ),
                  ],
                )),
          ],
        );
      case ExportDataType.water:
        // For water, we'll create a more detailed breakdown by drink type
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Total Daily Intake',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total Water (ml)',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...sortedDates.take(10).map((date) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(date),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(dailyTotals[date]!.toStringAsFixed(0)),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        );
      case ExportDataType.weight:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Weight',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows
            ...sortedDates.take(10).map((date) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(date),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(dailyTotals[date]!.toStringAsFixed(1)),
                    ),
                  ],
                )),
          ],
        );
      case ExportDataType.fiber:
        return pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Total Fiber (g)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows (limited to first 10 days to fit on page)
            ...sortedDates.take(10).map((date) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(date),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(dailyTotals[date]!.toStringAsFixed(1)),
                    ),
                  ],
                )),
          ],
        );
    }
  }

  // Build water summary tables with breakdown by drink type
  static pw.Widget _buildWaterSummaryTables(
    List<String> sortedDates,
    Map<String, double> dailyTotals,
    Map<String, Map<String, double>> totalsByType,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Total daily intake table
        pw.Text(
          'Total Daily Intake',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Total Water (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows
            ...sortedDates.take(10).map((date) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(date),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(dailyTotals[date]!.toStringAsFixed(0)),
                    ),
                  ],
                )),
          ],
        ),

        // Breakdown by drink type
        pw.SizedBox(height: 16),
        pw.Text(
          'Breakdown by Drink Type',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.2),
            5: const pw.FlexColumnWidth(1.2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Date',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Water (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Coffee (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Tea (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Juice (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Other (ml)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Data rows with breakdown by type
            ...sortedDates.take(10).map((date) {
              final typeData = totalsByType[date] ??
                  {
                    'water': 0.0,
                    'coffee': 0.0,
                    'tea': 0.0,
                    'juice': 0.0,
                    'other': 0.0,
                  };

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(date),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(typeData['water']!.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(typeData['coffee']!.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(typeData['tea']!.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(typeData['juice']!.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(typeData['other']!.toStringAsFixed(0)),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static List<String> _getCsvHeaders(ExportDataType dataType) {
    switch (dataType) {
      case ExportDataType.protein:
        return ['Date', 'Item', 'Protein (g)'];
      case ExportDataType.water:
        return ['Date', 'Time', 'Type', 'Amount (ml)', 'Note'];
      case ExportDataType.weight:
        return ['Date', 'Weight', 'Unit'];
      case ExportDataType.fiber:
        return ['Date', 'Item', 'Fiber (g)'];
    }
  }

  static List<dynamic> _getCsvRow(
      ExportDataType dataType, Map<String, dynamic> item) {
    switch (dataType) {
      case ExportDataType.protein:
        return [
          item['date'],
          item['item'],
          (item['protein'] as double).toStringAsFixed(1),
        ];
      case ExportDataType.water:
        return [
          item['date'],
          item['time'],
          item['type'],
          item['amount'].toString(),
          item['note'],
        ];
      case ExportDataType.weight:
        return [
          item['date'],
          (item['weight'] as double).toStringAsFixed(1),
          item['unit'],
        ];
      case ExportDataType.fiber:
        return [
          item['date'],
          item['item'],
          (item['fiber'] as double).toStringAsFixed(1),
        ];
    }
  }

  static String _getFileName(ExportDataType dataType, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    switch (dataType) {
      case ExportDataType.protein:
        return 'protein_report_$timestamp.$extension';
      case ExportDataType.water:
        return 'water_report_$timestamp.$extension';
      case ExportDataType.weight:
        return 'weight_report_$timestamp.$extension';
      case ExportDataType.fiber:
        return 'fiber_report_$timestamp.$extension';
    }
  }

  // Get dummy protein data for preview
  static List<Map<String, dynamic>> getDummyProteinData(
      DateTime startDate, DateTime endDate) {
    final dummyData = <Map<String, dynamic>>[];

    // Generate dummy data for each day in the range
    final days = endDate.difference(startDate).inDays + 1;
    final random = DateTime.now().millisecondsSinceEpoch;

    // Sample protein items
    final proteinItems = [
      {'name': 'Chicken Breast', 'protein': 31.0},
      {'name': 'Greek Yogurt', 'protein': 10.0},
      {'name': 'Protein Shake', 'protein': 25.0},
      {'name': 'Eggs (2)', 'protein': 12.0},
      {'name': 'Tuna', 'protein': 20.0},
      {'name': 'Cottage Cheese', 'protein': 14.0},
      {'name': 'Protein Bar', 'protein': 20.0},
      {'name': 'Tofu', 'protein': 8.0},
    ];

    // Generate 1-3 entries per day
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final entriesPerDay = 1 + (random % 3);

      for (var j = 0; j < entriesPerDay; j++) {
        final itemIndex = (random + i + j) % proteinItems.length;
        final item = proteinItems[itemIndex];

        dummyData.add({
          'date': DateFormat('yyyy-MM-dd').format(date),
          'item': item['name'] as String,
          'protein': item['protein'] as double,
        });
      }
    }

    return dummyData;
  }

  // Get dummy water data for preview
  static List<Map<String, dynamic>> getDummyWaterData(
      DateTime startDate, DateTime endDate) {
    final dummyData = <Map<String, dynamic>>[];

    // Generate dummy data for each day in the range
    final days = endDate.difference(startDate).inDays + 1;
    final random = DateTime.now().millisecondsSinceEpoch;

    // Sample water types
    final waterTypes = ['Water', 'Coffee', 'Tea', 'Juice', 'Water'];

    // Generate 2-5 entries per day
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final entriesPerDay = 2 + (random % 4);

      for (var j = 0; j < entriesPerDay; j++) {
        final typeIndex = (random + i + j) % waterTypes.length;
        final type = waterTypes[typeIndex];

        // Generate random amount between 100-500ml
        final amount = 100 + ((random + i * j) % 5) * 100;

        // Generate random time
        final hour = 8 + ((random + i + j) % 12);
        final minute = ((random + i * j) % 6) * 10;
        final time = DateTime(date.year, date.month, date.day, hour, minute);

        dummyData.add({
          'date': DateFormat('yyyy-MM-dd').format(date),
          'time': DateFormat('HH:mm').format(time),
          'type': type,
          'amount': amount,
          'note': '',
        });
      }
    }

    return dummyData;
  }

  // Get dummy weight data for preview
  static List<Map<String, dynamic>> getDummyWeightData(
      DateTime startDate, DateTime endDate) {
    final dummyData = <Map<String, dynamic>>[];

    // Generate dummy data for each day in the range (one entry per day)
    final days = endDate.difference(startDate).inDays + 1;
    final random = DateTime.now().millisecondsSinceEpoch;

    // Start with a base weight and fluctuate slightly
    final baseWeight = 70.0 + (random % 20);
    final unit = 'kg';

    for (var i = 0; i < days; i++) {
      // Only add weight entry every 2-3 days to be realistic
      if (i % 2 == 0 || i % 3 == 0) {
        final date = startDate.add(Duration(days: i));

        // Fluctuate weight by -0.3 to +0.3
        final fluctuation = ((random + i) % 7 - 3) / 10.0;
        final weight = baseWeight + fluctuation;

        dummyData.add({
          'date': DateFormat('yyyy-MM-dd').format(date),
          'weight': double.parse(weight.toStringAsFixed(1)),
          'unit': unit,
        });
      }
    }

    return dummyData;
  }
}
