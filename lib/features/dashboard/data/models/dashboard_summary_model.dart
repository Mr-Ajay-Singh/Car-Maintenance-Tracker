/// DashboardSummaryModel - Aggregated data model for dashboard display
/// No database storage - purely aggregation layer
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

/// VehicleSummary - Summary view of a vehicle for dashboard
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

  String get displayName => '$year $make $model';
}

/// UpcomingReminder - Summary of an upcoming maintenance reminder
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

  bool get isDueSoon {
    if (isOverdue) return false;
    if (daysRemaining != null && daysRemaining! <= 7) return true;
    if (odometerRemaining != null && odometerRemaining! <= 500) return true;
    return false;
  }
}

/// RecentActivity - Summary of recent activity (service, fuel, expense)
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

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

/// FuelEconomySummary - Summary of fuel economy for a period
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

  double get averagePricePerUnit {
    if (totalVolume == 0) return 0;
    return totalCost / totalVolume;
  }
}

/// ExpenseSummary - Summary of expenses for a period
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

  double get servicePercentage {
    if (totalExpenses == 0) return 0;
    return (serviceExpenses / totalExpenses) * 100;
  }

  double get fuelPercentage {
    if (totalExpenses == 0) return 0;
    return (fuelExpenses / totalExpenses) * 100;
  }

  double get otherPercentage {
    if (totalExpenses == 0) return 0;
    return (otherExpenses / totalExpenses) * 100;
  }
}
