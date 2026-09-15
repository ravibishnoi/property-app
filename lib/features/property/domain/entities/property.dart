class Property {
  final String id;
  final String name;
  final String type; // 'Apartment' | 'Villa' | 'Row House'
  final String location;
  final num price;
  final int area;
  final String areaUnit;
  final String configuration; // '1BHK', '2BHK', '3BHK', etc.
  final String status; // 'Available' | 'Sold' | 'Under Construction'
  final String description;
  final String imagePlaceholder;
  final String ownerId;

  const Property({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.area,
    required this.areaUnit,
    required this.configuration,
    required this.status,
    required this.description,
    required this.imagePlaceholder,
    required this.ownerId,
  });

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isSold => status.toLowerCase() == 'sold';
  bool get isUnderConstruction =>
      status.toLowerCase().contains('construction');

  num get pricePerSqft => area > 0 ? (price / area).round() : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
