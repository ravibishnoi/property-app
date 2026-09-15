import 'package:intl/intl.dart';

enum PropertyType {
  apartment('Apartment'),
  villa('Villa'),
  rowHouse('Row House');

  final String label;
  const PropertyType(this.label);

  static PropertyType? fromString(String? value) {
    if (value == null) return null;
    return PropertyType.values.firstWhere(
      (e) =>
          e.label.toLowerCase() == value.toLowerCase() ||
          e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PropertyType.apartment,
    );
  }
}

enum PropertyStatus {
  available('Available'),
  sold('Sold'),
  underConstruction('Under Construction');

  final String label;
  const PropertyStatus(this.label);

  static PropertyStatus? fromString(String? value) {
    if (value == null) return null;
    return PropertyStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => PropertyStatus.available,
    );
  }
}

class AppConstants {
  static const String appName = 'Property App';
  static const String appTagline = 'Curated Properties & Luxury Living';

  // Hive Box Names
  static const String usersBox = 'users_box';
  static const String propertiesBox = 'properties_box';
  static const String ownersBox = 'owners_box';
  static const String interestsBox = 'interests_box';

  // Asset paths
  static const String dbJsonPath = 'assets/data/db.json';

  // Format currency in Indian numbering format (Lakhs & Crores or comma separated)
  static String formatCurrency(num amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      final lk = amount / 100000;
      return '₹${lk.toStringAsFixed(lk.truncateToDouble() == lk ? 0 : 2)} Lakh';
    } else {
      final formatter =
          NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
      return formatter.format(amount);
    }
  }

  static String formatFullPrice(num amount) {
    final formatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  static String formatArea(int area, [String unit = 'sqft']) {
    final formatter = NumberFormat.decimalPattern();
    return '${formatter.format(area)} $unit';
  }
}
