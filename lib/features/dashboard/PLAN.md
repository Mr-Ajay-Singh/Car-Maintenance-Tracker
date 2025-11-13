# Dashboard Feature - Implementation Plan

## Feature Overview
The Dashboard is the main landing page after login, providing an at-a-glance overview of the user's vehicles, upcoming maintenance reminders, recent activities, fuel economy, and quick actions. This feature aggregates data from other modules to present a comprehensive status.

## Architecture
Following CLAUDE.md guidelines:
- **Data Layer**: Dashboard aggregation models
- **Service Layer**: Business logic to collect and format dashboard data
- **Presentation Layer**: UI components (implemented in UI.md)

---

## Data Layer

### Dashboard Summary Model

**File**: `lib/features/dashboard/data/models/dashboard_summary_model.dart`

```dart
class DashboardSummaryModel {
  final String userId;
  final List<VehicleSummary> vehicles;
  final List<UpcomingReminder> upcomingReminders;
  final List<RecentActivity> recentActivities;
  final FuelEconomySummary? fuelSummary;
  final ExpenseSummary? expenseSummary;
  final DateTime lastUpdated;

  DashboardSummaryModel({
    required this.userId,
    required this.vehicles,
    required this.upcomingReminders,
    required this.recentActivities,
    this.fuelSummary,
    this.expenseSummary,
    required this.lastUpdated,
  });
}

class VehicleSummary {
  final String vehicleId;
  final String make;
  final String model;
  final int year;
  final int currentOdometer;
  final DateTime? lastServiceDate;
  final String? lastServiceType;
  final int? nextServiceDue; // odometer reading
  final int? daysUntilNextService;

  VehicleSummary({
    required this.vehicleId,
    required this.make,
    required this.model,
    required this.year,
    required this.currentOdometer,
    this.lastServiceDate,
    this.lastServiceType,
    this.nextServiceDue,
    this.daysUntilNextService,
  });
}

class UpcomingReminder {
  final String id;
  final String vehicleId;
  final String title;
  final String type; // service, insurance, registration
  final DateTime? dueDate;
  final int? dueOdometer;
  final bool isOverdue;
  final int? daysRemaining;
  final int? odometerRemaining;

  UpcomingReminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.type,
    this.dueDate,
    this.dueOdometer,
    required this.isOverdue,
    this.daysRemaining,
    this.odometerRemaining,
  });
}

class RecentActivity {
  final String id;
  final String vehicleId;
  final String type; // service, fuel, expense
  final String title;
  final DateTime date;
  final double? amount;
  final String? icon;

  RecentActivity({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.title,
    required this.date,
    this.amount,
    this.icon,
  });
}

class FuelEconomySummary {
  final double averageMpg;
  final double totalCost;
  final double totalVolume;
  final String period; // "This month", "Last 30 days"

  FuelEconomySummary({
    required this.averageMpg,
    required this.totalCost,
    required this.totalVolume,
    required this.period,
  });
}

class ExpenseSummary {
  final double totalExpenses;
  final double serviceExpenses;
  final double fuelExpenses;
  final double otherExpenses;
  final String period; // "This month", "Last 30 days"

  ExpenseSummary({
    required this.totalExpenses,
    required this.serviceExpenses,
    required this.fuelExpenses,
    required this.otherExpenses,
    required this.period,
  });
}
```

---

## Service Layer

### Dashboard Service

**File**: `lib/features/dashboard/service/dashboard_service.dart`

```dart
class DashboardService {
  final VehicleService _vehicleService = VehicleService();
  final ServiceEntryService _serviceService = ServiceEntryService();
  final FuelEntryService _fuelService = FuelEntryService();
  final ExpenseService _expenseService = ExpenseService();
  final ReminderService _reminderService = ReminderService();

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
      daysUntilNext = nextReminder!.dueDate!.difference(DateTime.now()).inDays;
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

  Future<List<UpcomingReminder>> _getUpcomingReminders(
    String userId,
    {int limit = 5}
  ) async {
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

    return allReminders.take(limit).map((r) {
      int? daysRemaining;
      if (r.dueDate != null) {
        daysRemaining = r.dueDate!.difference(DateTime.now()).inDays;
      }

      int? odometerRemaining;
      if (r.dueOdometer != null) {
        // Would need vehicle current odometer
        // odometerRemaining = r.dueOdometer - vehicle.currentOdometer;
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

  Future<List<RecentActivity>> _getRecentActivities(
    String userId,
    {int limit = 10}
  ) async {
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

  Future<FuelEconomySummary?> _getFuelSummary(
    List<VehicleModel> vehicles,
  ) async {
    if (vehicles.isEmpty) return null;

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    double totalCost = 0;
    double totalVolume = 0;
    final economies = <double>[];

    for (final vehicle in vehicles) {
      final cost = await _fuelService.getTotalCost(
        vehicle.id,
        thirtyDaysAgo,
        now,
      );
      final volume = await _fuelService.getTotalVolume(
        vehicle.id,
        thirtyDaysAgo,
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
      period: 'Last 30 days',
    );
  }

  Future<ExpenseSummary?> _getExpenseSummary(
    List<VehicleModel> vehicles,
  ) async {
    if (vehicles.isEmpty) return null;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    double totalExpenses = 0;
    double serviceExpenses = 0;
    double fuelExpenses = 0;
    double otherExpenses = 0;

    for (final vehicle in vehicles) {
      // Service costs
      final serviceCost = await _serviceService.getTotalCost(
        vehicle.id,
        monthStart,
        monthEnd,
      );
      serviceExpenses += serviceCost;

      // Fuel costs
      final fuelCost = await _fuelService.getTotalCost(
        vehicle.id,
        monthStart,
        monthEnd,
      );
      fuelExpenses += fuelCost;

      // Other expenses
      final expenses = await _expenseService.getTotalExpenses(
        vehicle.id,
        monthStart,
        monthEnd,
      );
      otherExpenses += expenses;
    }

    totalExpenses = serviceExpenses + fuelExpenses + otherExpenses;

    return ExpenseSummary(
      totalExpenses: totalExpenses,
      serviceExpenses: serviceExpenses,
      fuelExpenses: fuelExpenses,
      otherExpenses: otherExpenses,
      period: 'This month',
    );
  }

  // Quick actions
  Future<void> logQuickService(
    String vehicleId,
    String userId,
    String serviceType,
  ) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) return;

    final entry = ServiceEntryModel(
      id: Uuid().v4(),
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

  Future<void> logQuickFuel(
    String vehicleId,
    String userId,
    double volume,
    double cost,
  ) async {
    final vehicle = await _vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) return;

    final entry = FuelEntryModel(
      id: Uuid().v4(),
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
}
```

---

## Implementation Checklist

- [ ] Create dashboard summary models
- [ ] Create DashboardService to aggregate data
- [ ] Implement vehicle summary builder
- [ ] Implement upcoming reminders aggregation
- [ ] Implement recent activities aggregation
- [ ] Implement fuel summary calculations
- [ ] Implement expense summary calculations
- [ ] Add quick action methods
- [ ] Test data aggregation from all modules
- [ ] Test performance with multiple vehicles

---

## Notes

- Dashboard pulls data from multiple services (Vehicle, Service, Fuel, Expense, Reminder)
- No database tables needed - purely aggregation layer
- Caching recommended for performance
- Quick actions provide shortcuts to common tasks
- Summary period configurable (30 days, this month, etc.)
