import 'package:uuid/uuid.dart';
import '../../expenses/data/models/expense_model.dart';
import '../../expenses/service/expense_service.dart';
import '../../fuel/data/models/fuel_entry_model.dart';
import '../../fuel/service/fuel_entry_service.dart';
import '../../reminders/data/models/reminder_model.dart';
import '../../reminders/service/reminder_service.dart';
import '../../service_log/data/models/service_entry_model.dart';
import '../../service_log/service/service_entry_service.dart';
import '../../vehicle/data/models/vehicle_model.dart';
import '../../vehicle/service/vehicle_service.dart';
import '../data/models/dashboard_summary_model.dart';

/// DashboardService - Service class for aggregating dashboard data
/// Pulls data from all other feature services to create dashboard summary
class DashboardService {
  final VehicleService _vehicleService = VehicleService();
  final ServiceEntryService _serviceService = ServiceEntryService();
  final FuelEntryService _fuelService = FuelEntryService();
  final ExpenseService _expenseService = ExpenseService();
  final ReminderService _reminderService = ReminderService();

  /// Get complete dashboard summary for a user
  Future<DashboardSummaryModel> getDashboardSummary(String userId) async {
    // Get all vehicles
    final vehicles = await _vehicleService.getAllVehicles(userId);

    // Build vehicle summaries
    final vehicleSummaries = await Future.wait(
      vehicles.map((v) => _buildVehicleSummary(v)),
    );

    // Get upcoming reminders (next 5)
    final upcomingReminders = await _getUpcomingReminders(userId, limit: 5);

    // Get recent activities (last 10)
    final recentActivities = await _getRecentActivities(userId, limit: 10);

    // Get fuel summary (last 30 days)
    final fuelSummary = await _getFuelSummary(vehicles);

    // Get expense summary (this month)
    final expenseSummary = await _getExpenseSummary(vehicles);

    return DashboardSummaryModel(
      userId: userId,
      vehicles: vehicleSummaries,
      upcomingReminders: upcomingReminders,
      recentActivities: recentActivities,
      fuelSummary: fuelSummary,
      expenseSummary: expenseSummary,
      lastUpdated: DateTime.now(),
    );
  }

  /// Build summary for a single vehicle
  Future<VehicleSummary> _buildVehicleSummary(VehicleModel vehicle) async {
    // Get last service
    final recentServices = await _serviceService.getRecentEntries(
      vehicle.id,
      1,
    );

    final lastService = recentServices.isNotEmpty ? recentServices.first : null;

    // Get next reminder due
    final reminders = await _reminderService.getActiveReminders(vehicle.id);
    final nextReminder = reminders.isNotEmpty ? reminders.first : null;

    int? daysUntilNext;
    if (nextReminder?.dueDate != null) {
      daysUntilNext =
          nextReminder!.dueDate!.difference(DateTime.now()).inDays;
    }

    return VehicleSummary(
      vehicleId: vehicle.id,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      currentOdometer: vehicle.currentOdometer,
      lastServiceDate: lastService?.date,
      lastServiceType: lastService?.serviceType,
      nextServiceDue: nextReminder?.dueOdometer,
      daysUntilNextService: daysUntilNext,
    );
  }

  /// Get upcoming reminders across all vehicles
  Future<List<UpcomingReminder>> _getUpcomingReminders(
    String userId, {
    int limit = 5,
  }) async {
    final vehicles = await _vehicleService.getAllVehicles(userId);
    final allReminders = <ReminderModel>[];

    for (final vehicle in vehicles) {
      final reminders = await _reminderService.getActiveReminders(vehicle.id);
      allReminders.addAll(reminders);
    }

    // Sort by urgency (overdue first, then by days/odometer remaining)
    allReminders.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }

      return 0;
    });

    // Get vehicle info for odometer remaining calculation
    final vehicleMap = <String, VehicleModel>{};
    for (final vehicle in vehicles) {
      vehicleMap[vehicle.id] = vehicle;
    }

    return allReminders.take(limit).map((r) {
      int? daysRemaining;
      if (r.dueDate != null) {
        daysRemaining = r.dueDate!.difference(DateTime.now()).inDays;
      }

      int? odometerRemaining;
      if (r.dueOdometer != null) {
        final vehicle = vehicleMap[r.vehicleId];
        if (vehicle != null) {
          odometerRemaining = r.dueOdometer! - vehicle.currentOdometer;
        }
      }

      return UpcomingReminder(
        id: r.id,
        vehicleId: r.vehicleId,
        title: r.title,
        type: r.type,
        dueDate: r.dueDate,
        dueOdometer: r.dueOdometer,
        isOverdue: r.isOverdue,
        daysRemaining: daysRemaining,
        odometerRemaining: odometerRemaining,
      );
    }).toList();
  }

  /// Get recent activities across all types
  Future<List<RecentActivity>> _getRecentActivities(
    String userId, {
    int limit = 10,
  }) async {
    final activities = <RecentActivity>[];

    // Get recent service entries
    final services = await _serviceService.getAllEntries(userId);
    activities.addAll(
      services.take(5).map((s) => RecentActivity(
            id: s.id,
            vehicleId: s.vehicleId,
            type: 'service',
            title: s.serviceType,
            date: s.date,
            amount: s.totalCost,
            icon: 'build',
          )),
    );

    // Get recent fuel entries
    final fuelEntries = await _fuelService.getAllEntries(userId);
    activities.addAll(
      fuelEntries.take(5).map((f) => RecentActivity(
            id: f.id,
            vehicleId: f.vehicleId,
            type: 'fuel',
            title: 'Fuel fill-up',
            date: f.date,
            amount: f.cost,
            icon: 'local_gas_station',
          )),
    );

    // Get recent expenses
    final expenses = await _expenseService.getAllExpenses(userId);
    activities.addAll(
      expenses.take(5).map((e) => RecentActivity(
            id: e.id,
            vehicleId: e.vehicleId,
            type: 'expense',
            title: e.category,
            date: e.date,
            amount: e.amount,
            icon: 'receipt',
          )),
    );

    // Sort by date descending and return top N
    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(limit).toList();
  }

  /// Calculate fuel economy summary for last 30 days
  Future<FuelEconomySummary?> _getFuelSummary(
    List<VehicleModel> vehicles,
  ) async {
    if (vehicles.isEmpty) return null;

    final now = DateTime.now();
    // Use a far past date to get "All Time" stats
    final allTimeStart = DateTime(2000);

    double totalCost = 0;
    double totalVolume = 0;
    final economies = <double>[];

    for (final vehicle in vehicles) {
      final cost = await _fuelService.getTotalCost(
        vehicle.id,
        allTimeStart,
        now,
      );
      final volume = await _fuelService.getTotalVolume(
        vehicle.id,
        allTimeStart,
        now,
      );
      final avgEconomy = await _fuelService.getAverageFuelEconomy(vehicle.id);

      totalCost += cost;
      totalVolume += volume;
      if (avgEconomy > 0) economies.add(avgEconomy);
    }

    final avgMpg = economies.isNotEmpty
        ? economies.reduce((a, b) => a + b) / economies.length
        : 0.0;

    return FuelEconomySummary(
      averageMpg: avgMpg,
      totalCost: totalCost,
      totalVolume: totalVolume,
      period: 'All Time',
    );
  }

  /// Calculate expense summary for all time
  Future<ExpenseSummary?> _getExpenseSummary(
    List<VehicleModel> vehicles,
  ) async {
    if (vehicles.isEmpty) return null;

    final now = DateTime.now();
    // Use a far past date to get "All Time" stats
    final allTimeStart = DateTime(2000);

    double totalExpenses = 0;
    double serviceExpenses = 0;
    double fuelExpenses = 0;
    double otherExpenses = 0;

    for (final vehicle in vehicles) {
      // Service costs
      final serviceCost = await _serviceService.getTotalCost(
        vehicle.id,
        allTimeStart,
        now,
      );
      serviceExpenses += serviceCost;

      // Fuel costs
      final fuelCost = await _fuelService.getTotalCost(
        vehicle.id,
        allTimeStart,
        now,
      );
      fuelExpenses += fuelCost;

      // Other expenses
      final expenses = await _expenseService.getTotalExpenses(
        vehicle.id,
        allTimeStart,
        now,
      );
      otherExpenses += expenses;
    }

    totalExpenses = serviceExpenses + fuelExpenses + otherExpenses;

    return ExpenseSummary(
      totalExpenses: totalExpenses,
      serviceExpenses: serviceExpenses,
      fuelExpenses: fuelExpenses,
      otherExpenses: otherExpenses,
      period: 'All Time',
    );
  }

  // ==================== QUICK ACTIONS ====================

  /// Quick log a service entry with minimal info
  Future<void> logQuickService(
    String vehicleId,
    String userId,
    String serviceType,
  ) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) return;

    final entry = ServiceEntryModel(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      userId: userId,
      date: DateTime.now(),
      odometer: vehicle.currentOdometer,
      serviceType: serviceType,
      totalCost: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _serviceService.addServiceEntry(entry);
  }

  /// Quick log a fuel entry
  Future<void> logQuickFuel(
    String vehicleId,
    String userId,
    double volume,
    double cost,
  ) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) return;

    final entry = FuelEntryModel(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      userId: userId,
      date: DateTime.now(),
      odometer: vehicle.currentOdometer,
      volume: volume,
      cost: cost,
      pricePerUnit: cost / volume,
      fuelType: vehicle.fuelType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _fuelService.addFuelEntry(entry);
  }

  /// Quick log an expense
  Future<void> logQuickExpense(
    String vehicleId,
    String userId,
    String category,
    double amount,
  ) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) return;

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      vehicleId: vehicleId,
      userId: userId,
      date: DateTime.now(),
      category: category,
      amount: amount,
      currency: 'USD', // Default, should come from settings
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _expenseService.addExpense(expense);
  }
}
