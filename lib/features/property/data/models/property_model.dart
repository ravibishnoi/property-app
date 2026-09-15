import '../../domain/entities/property.dart';

class PropertyModel {
  final String id;
  final String name;
  final String type;
  final String location;
  final num price;
  final int area;
  final String areaUnit;
  final String configuration;
  final String status;
  final String description;
  final String imagePlaceholder;
  final String ownerId;

  const PropertyModel({
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

  factory PropertyModel.fromMap(Map<dynamic, dynamic> map) {
    return PropertyModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Apartment',
      location: map['location']?.toString() ?? '',
      price: map['price'] is num ? map['price'] : num.tryParse(map['price']?.toString() ?? '0') ?? 0,
      area: map['area'] is int ? map['area'] : int.tryParse(map['area']?.toString() ?? '0') ?? 0,
      areaUnit: map['areaUnit']?.toString() ?? 'sqft',
      configuration: map['configuration']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Available',
      description: map['description']?.toString() ?? '',
      imagePlaceholder: map['imagePlaceholder']?.toString() ?? 'assets/images/img-1.png',
      ownerId: map['ownerId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'price': price,
      'area': area,
      'areaUnit': areaUnit,
      'configuration': configuration,
      'status': status,
      'description': description,
      'imagePlaceholder': imagePlaceholder,
      'ownerId': ownerId,
    };
  }

  Property toEntity() {
    return Property(
      id: id,
      name: name,
      type: type,
      location: location,
      price: price,
      area: area,
      areaUnit: areaUnit,
      configuration: configuration,
      status: status,
      description: description,
      imagePlaceholder: imagePlaceholder,
      ownerId: ownerId,
    );
  }
}
