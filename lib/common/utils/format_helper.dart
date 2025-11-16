import '../data/shared_preferences_helper.dart';

/// FormatHelper - Centralized formatting for currency, volume, distance, and dates
/// Uses user preferences from SharedPreferences
class FormatHelper {
  // Currency symbols
  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CNY': '¥',
  };

  // Volume unit labels
  static const Map<String, String> _volumeUnitLabels = {
    'L': 'L',
    'gal': 'gal',
    'gal_uk': 'gal',
  };

  // Distance unit labels
  static const Map<String, String> _distanceUnitLabels = {
    'km': 'km',
    'mi': 'mi',
  };

  /// Format currency with user's preferred currency
  static Future<String> formatCurrency(double amount) async {
    final currency = await SharedPreferencesHelper.getCurrency();
    final symbol = _currencySymbols[currency] ?? '\$';

    // Special formatting for JPY and CNY (no decimal places)
    if (currency == 'JPY' || currency == 'CNY') {
      return '$symbol${amount.round()}';
    }

    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Get currency symbol
  static Future<String> getCurrencySymbol() async {
    final currency = await SharedPreferencesHelper.getCurrency();
    return _currencySymbols[currency] ?? '\$';
  }

  /// Format volume with user's preferred unit
  static Future<String> formatVolume(double volume) async {
    final unit = await SharedPreferencesHelper.getVolumeUnit();
    final label = _volumeUnitLabels[unit] ?? 'L';

    // Convert if needed
    double displayValue = volume;
    if (unit == 'gal') {
      // Convert liters to US gallons (1 L = 0.264172 gal)
      displayValue = volume * 0.264172;
    } else if (unit == 'gal_uk') {
      // Convert liters to UK gallons (1 L = 0.219969 gal)
      displayValue = volume * 0.219969;
    }

    return '${displayValue.toStringAsFixed(2)} $label';
  }

  /// Get volume unit label
  static Future<String> getVolumeUnit() async {
    final unit = await SharedPreferencesHelper.getVolumeUnit();
    return _volumeUnitLabels[unit] ?? 'L';
  }

  /// Format distance with user's preferred unit
  static Future<String> formatDistance(int distance) async {
    final unit = await SharedPreferencesHelper.getDistanceUnit();
    final label = _distanceUnitLabels[unit] ?? 'km';

    // Convert if needed
    double displayValue = distance.toDouble();
    if (unit == 'mi') {
      // Convert km to miles (1 km = 0.621371 mi)
      displayValue = distance * 0.621371;
    }

    // Format with thousands separator
    final formatted = displayValue.round().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return '$formatted $label';
  }

  /// Get distance unit label
  static Future<String> getDistanceUnit() async {
    final unit = await SharedPreferencesHelper.getDistanceUnit();
    return _distanceUnitLabels[unit] ?? 'km';
  }

  /// Format date as DD/MM/YYYY
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format date as "X days ago", "Yesterday", "Today", etc.
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).floor()} weeks ago';
    if (difference < 365) return '${(difference / 30).floor()} months ago';
    return formatDate(date);
  }

  /// Format number with thousands separator
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Format price per unit (for fuel)
  static Future<String> formatPricePerUnit(double price) async {
    final currencySymbol = await getCurrencySymbol();
    final volumeUnit = await getVolumeUnit();
    return '$currencySymbol${price.toStringAsFixed(2)}/$volumeUnit';
  }

  /// Format fuel economy (km/L or mpg)
  static Future<String> formatFuelEconomy(double kmPerLiter) async {
    final distanceUnit = await SharedPreferencesHelper.getDistanceUnit();
    final volumeUnit = await SharedPreferencesHelper.getVolumeUnit();

    double displayValue = kmPerLiter;
    String label = 'km/L';

    if (distanceUnit == 'mi' && volumeUnit == 'gal') {
      // Convert km/L to mpg (1 km/L = 2.35215 mpg)
      displayValue = kmPerLiter * 2.35215;
      label = 'mpg';
    } else if (distanceUnit == 'mi' && volumeUnit == 'gal_uk') {
      // Convert km/L to UK mpg (1 km/L = 2.82481 mpg UK)
      displayValue = kmPerLiter * 2.82481;
      label = 'mpg';
    } else if (distanceUnit == 'mi') {
      displayValue = kmPerLiter * 0.621371; // km/L to mi/L
      label = 'mi/L';
    } else if (volumeUnit == 'gal') {
      displayValue = kmPerLiter / 0.264172; // km/L to km/gal
      label = 'km/gal';
    } else if (volumeUnit == 'gal_uk') {
      displayValue = kmPerLiter / 0.219969; // km/L to km/gal UK
      label = 'km/gal';
    }

    return '${displayValue.toStringAsFixed(1)} $label';
  }
}
