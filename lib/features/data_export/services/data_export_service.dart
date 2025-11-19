import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

import '../../../common/data/database_helper.dart';
import '../../vehicle/data/models/vehicle_model.dart';
import '../../service_log/data/models/service_entry_model.dart';
import '../../fuel/data/models/fuel_entry_model.dart';
import '../../reminders/data/models/reminder_model.dart';
import '../../expenses/data/models/expense_model.dart';

enum ExportDataType {
  vehicles,
  serviceEntries,
  fuelEntries,
  reminders,
  expenses,
  allData,
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
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get available export data types
  static List<ExportData> getAvailableExportTypes() {
    return [
      const ExportData(
        title: 'All Vehicle Data',
        description: 'Export complete vehicle maintenance history',
        icon: Icons.cloud_download_rounded,
        type: ExportDataType.allData,
      ),
      const ExportData(
        title: 'Service Records',
        description: 'Export service and maintenance history',
        icon: Icons.build_rounded,
        type: ExportDataType.serviceEntries,
      ),
      const ExportData(
        title: 'Fuel Records',
        description: 'Export fuel and mileage tracking',
        icon: Icons.local_gas_station_rounded,
        type: ExportDataType.fuelEntries,
      ),
      const ExportData(
        title: 'Expense Records',
        description: 'Export expense and cost tracking',
        icon: Icons.attach_money_rounded,
        type: ExportDataType.expenses,
      ),
      const ExportData(
        title: 'Reminders',
        description: 'Export maintenance reminders',
        icon: Icons.notifications_active_rounded,
        type: ExportDataType.reminders,
      ),
    ];
  }

  // ==================== DATA RETRIEVAL METHODS ====================

  /// Get vehicle data for export
  static Future<List<Map<String, dynamic>>> getVehicleData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(VehicleModel.queryGetAll, [userId]);

    // Filter by date range based on createdAt
    final filteredRows = rows.where((row) {
      final createdAt = DateTime.parse(row['createdAt'] as String);
      return createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
          createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredRows.map((row) {
      final vehicle = VehicleModel.fromMap(row);
      return {
        'make': vehicle.make,
        'model': vehicle.model,
        'year': vehicle.year.toString(),
        'vin': vehicle.vin ?? 'N/A',
        'license': vehicle.licensePlate ?? 'N/A',
        'odometer': '${vehicle.currentOdometer} km',
        'fuelType': vehicle.fuelType,
        'purchaseDate': vehicle.purchaseDate != null
            ? DateFormat('yyyy-MM-dd').format(vehicle.purchaseDate!)
            : 'N/A',
      };
    }).toList();
  }

  /// Get service entry data for export
  static Future<List<Map<String, dynamic>>> getServiceEntryData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(ServiceEntryModel.queryGetAll, [userId]);

    // Filter by date range
    final filteredRows = rows.where((row) {
      final date = DateTime.parse(row['date'] as String);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredRows.map((row) {
      final entry = ServiceEntryModel.fromMap(row);
      return {
        'date': DateFormat('yyyy-MM-dd').format(entry.date),
        'serviceType': entry.serviceType,
        'odometer': '${entry.odometer} km',
        'cost': '\$${entry.totalCost.toStringAsFixed(2)}',
        'shopName': entry.shopName ?? 'N/A',
        'notes': entry.notes ?? '',
      };
    }).toList();
  }

  /// Get fuel entry data for export
  static Future<List<Map<String, dynamic>>> getFuelEntryData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(FuelEntryModel.queryGetAll, [userId]);

    // Filter by date range
    final filteredRows = rows.where((row) {
      final date = DateTime.parse(row['date'] as String);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredRows.map((row) {
      final entry = FuelEntryModel.fromMap(row);
      return {
        'date': DateFormat('yyyy-MM-dd').format(entry.date),
        'odometer': '${entry.odometer} km',
        'volume': '${entry.volume.toStringAsFixed(2)} L',
        'cost': '\$${entry.cost.toStringAsFixed(2)}',
        'pricePerUnit': '\$${entry.pricePerUnit.toStringAsFixed(2)}/L',
        'isFull': entry.isFullTank ? 'Full Tank' : 'Partial',
        'station': entry.stationName ?? 'N/A',
      };
    }).toList();
  }

  /// Get reminder data for export
  static Future<List<Map<String, dynamic>>> getReminderData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(ReminderModel.queryGetAll, [userId]);

    // Filter by date range based on dueDate
    final filteredRows = rows.where((row) {
      final dueDateStr = row['dueDate'] as String?;
      if (dueDateStr == null) return false;

      final dueDate = DateTime.parse(dueDateStr);
      return dueDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          dueDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredRows.map((row) {
      final reminder = ReminderModel.fromMap(row);
      return {
        'title': reminder.title,
        'description': reminder.description ?? '',
        'type': reminder.type,
        'dueDate': reminder.dueDate != null
            ? DateFormat('yyyy-MM-dd').format(reminder.dueDate!)
            : 'N/A',
        'dueOdometer': reminder.dueOdometer != null
            ? '${reminder.dueOdometer} km'
            : 'N/A',
        'status': reminder.isCompleted ? 'Completed' : 'Pending',
      };
    }).toList();
  }

  /// Get expense data for export
  static Future<List<Map<String, dynamic>>> getExpenseData(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(ExpenseModel.queryGetAll, [userId]);

    // Filter by date range
    final filteredRows = rows.where((row) {
      final date = DateTime.parse(row['date'] as String);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredRows.map((row) {
      final expense = ExpenseModel.fromMap(row);
      return {
        'date': DateFormat('yyyy-MM-dd').format(expense.date),
        'category': expense.category,
        'amount': '\$${expense.amount.toStringAsFixed(2)}',
        'description': expense.description ?? '',
      };
    }).toList();
  }

  // ==================== EXPORT TO PDF ====================

  static Future<File> exportToPdf({
    required ExportDataType dataType,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> data,
  }) async {
    final pdf = pw.Document();

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
                pw.SizedBox(height: 60),
                pw.Text(
                  'Generated on ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Add data pages
    if (data.isNotEmpty) {
      final chunks = <List<Map<String, dynamic>>>[];
      for (var i = 0; i < data.length; i += 15) {
        chunks.add(data.skip(i).take(15).toList());
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
                    'Records',
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

  // ==================== EXPORT TO CSV ====================

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

  // ==================== HELPER METHODS ====================

  static String _getReportTitle(ExportDataType dataType) {
    switch (dataType) {
      case ExportDataType.vehicles:
        return 'Vehicle Information Report';
      case ExportDataType.serviceEntries:
        return 'Service Records Report';
      case ExportDataType.fuelEntries:
        return 'Fuel Records Report';
      case ExportDataType.reminders:
        return 'Maintenance Reminders Report';
      case ExportDataType.expenses:
        return 'Expense Records Report';
      case ExportDataType.allData:
        return 'Complete Vehicle Data Report';
    }
  }

  static pw.Widget _buildDataTable(
    ExportDataType dataType,
    List<Map<String, dynamic>> data,
  ) {
    final headers = _getCsvHeaders(dataType);

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                header,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...data.map((item) {
          final row = _getCsvRow(dataType, item);
          return pw.TableRow(
            children: row.map((cell) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(cell.toString()),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  static List<String> _getCsvHeaders(ExportDataType dataType) {
    switch (dataType) {
      case ExportDataType.vehicles:
        return ['Make', 'Model', 'Year', 'VIN', 'License', 'Odometer', 'Fuel Type', 'Purchase Date'];
      case ExportDataType.serviceEntries:
        return ['Date', 'Service Type', 'Odometer', 'Cost', 'Shop Name', 'Notes'];
      case ExportDataType.fuelEntries:
        return ['Date', 'Odometer', 'Volume', 'Cost', 'Price/Unit', 'Fill Type', 'Station'];
      case ExportDataType.reminders:
        return ['Title', 'Description', 'Type', 'Due Date', 'Due Odometer', 'Status'];
      case ExportDataType.expenses:
        return ['Date', 'Category', 'Amount', 'Description'];
      case ExportDataType.allData:
        return ['Type', 'Date', 'Details'];
    }
  }

  static List<dynamic> _getCsvRow(
    ExportDataType dataType,
    Map<String, dynamic> item,
  ) {
    switch (dataType) {
      case ExportDataType.vehicles:
        return [
          item['make'],
          item['model'],
          item['year'],
          item['vin'],
          item['license'],
          item['odometer'],
          item['fuelType'],
          item['purchaseDate'],
        ];
      case ExportDataType.serviceEntries:
        return [
          item['date'],
          item['serviceType'],
          item['odometer'],
          item['cost'],
          item['shopName'],
          item['notes'],
        ];
      case ExportDataType.fuelEntries:
        return [
          item['date'],
          item['odometer'],
          item['volume'],
          item['cost'],
          item['pricePerUnit'],
          item['isFull'],
          item['station'],
        ];
      case ExportDataType.reminders:
        return [
          item['title'],
          item['description'],
          item['type'],
          item['dueDate'],
          item['dueOdometer'],
          item['status'],
        ];
      case ExportDataType.expenses:
        return [
          item['date'],
          item['category'],
          item['amount'],
          item['description'],
        ];
      case ExportDataType.allData:
        return [
          item['type'] ?? '',
          item['date'] ?? '',
          item['details'] ?? '',
        ];
    }
  }

  static String _getFileName(ExportDataType dataType, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    switch (dataType) {
      case ExportDataType.vehicles:
        return 'vehicles_$timestamp.$extension';
      case ExportDataType.serviceEntries:
        return 'service_records_$timestamp.$extension';
      case ExportDataType.fuelEntries:
        return 'fuel_records_$timestamp.$extension';
      case ExportDataType.reminders:
        return 'reminders_$timestamp.$extension';
      case ExportDataType.expenses:
        return 'expenses_$timestamp.$extension';
      case ExportDataType.allData:
        return 'all_vehicle_data_$timestamp.$extension';
    }
  }

  // ==================== DUMMY DATA FOR PREVIEW ====================

  static List<Map<String, dynamic>> getDummyServiceData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final dummyData = <Map<String, dynamic>>[];
    final days = endDate.difference(startDate).inDays + 1;

    final serviceTypes = ['Oil Change', 'Tire Rotation', 'Brake Service', 'Air Filter'];
    final shops = ['Auto Center', 'Quick Lube', 'Main Street Garage'];

    for (var i = 0; i < days.clamp(0, 10); i++) {
      final date = startDate.add(Duration(days: i * (days ~/ 10)));
      dummyData.add({
        'date': DateFormat('yyyy-MM-dd').format(date),
        'serviceType': serviceTypes[i % serviceTypes.length],
        'odometer': '${45000 + (i * 500)} km',
        'cost': '\$${(50 + i * 15).toStringAsFixed(2)}',
        'shopName': shops[i % shops.length],
        'notes': 'Regular maintenance',
      });
    }

    return dummyData;
  }

  static List<Map<String, dynamic>> getDummyFuelData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final dummyData = <Map<String, dynamic>>[];
    final days = endDate.difference(startDate).inDays + 1;

    for (var i = 0; i < days.clamp(0, 15); i++) {
      final date = startDate.add(Duration(days: i * (days ~/ 15)));
      dummyData.add({
        'date': DateFormat('yyyy-MM-dd').format(date),
        'odometer': '${45000 + (i * 350)} km',
        'volume': '${(40 + i % 10).toStringAsFixed(2)} L',
        'cost': '\$${(60 + i * 2).toStringAsFixed(2)}',
        'pricePerUnit': '\$${(1.45 + (i % 5) * 0.05).toStringAsFixed(2)}/L',
        'isFull': i % 2 == 0 ? 'Full Tank' : 'Partial',
        'station': 'Gas Station ${i % 3 + 1}',
      });
    }

    return dummyData;
  }

  static List<Map<String, dynamic>> getDummyExpenseData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final dummyData = <Map<String, dynamic>>[];
    final days = endDate.difference(startDate).inDays + 1;

    final categories = ['Fuel', 'Maintenance', 'Insurance', 'Parking'];
    final descriptions = [
      'Regular fuel purchase',
      'Oil change service',
      'Monthly insurance payment',
      'Downtown parking fee'
    ];

    for (var i = 0; i < days.clamp(0, 12); i++) {
      final date = startDate.add(Duration(days: i * (days ~/ 12)));
      dummyData.add({
        'date': DateFormat('yyyy-MM-dd').format(date),
        'category': categories[i % categories.length],
        'amount': '\$${(25 + i * 10).toStringAsFixed(2)}',
        'description': descriptions[i % descriptions.length],
      });
    }

    return dummyData;
  }

  static List<Map<String, dynamic>> getDummyReminderData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final dummyData = <Map<String, dynamic>>[];

    dummyData.addAll([
      {
        'title': 'Oil Change Due',
        'description': 'Every 5,000 km',
        'type': 'Odometer',
        'dueDate': DateFormat('yyyy-MM-dd').format(startDate.add(const Duration(days: 15))),
        'dueOdometer': '50000 km',
        'status': 'Pending',
      },
      {
        'title': 'Tire Rotation',
        'description': 'Rotate tires for even wear',
        'type': 'Odometer',
        'dueDate': DateFormat('yyyy-MM-dd').format(startDate.add(const Duration(days: 30))),
        'dueOdometer': '51000 km',
        'status': 'Pending',
      },
      {
        'title': 'Annual Inspection',
        'description': 'State safety inspection',
        'type': 'Date',
        'dueDate': DateFormat('yyyy-MM-dd').format(startDate.add(const Duration(days: 45))),
        'dueOdometer': 'N/A',
        'status': 'Pending',
      },
    ]);

    return dummyData;
  }
}
