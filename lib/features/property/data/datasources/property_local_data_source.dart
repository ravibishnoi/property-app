import 'package:property_app/core/di/hive_boxes.dart';
import '../../domain/entities/property_filter.dart';
import '../models/property_model.dart';

abstract class PropertyLocalDataSource {
  Future<List<PropertyModel>> getProperties({PropertyFilter? filter});
  Future<PropertyModel?> getPropertyById(String id);
  Future<List<PropertyModel>> getPropertiesByOwnerId(String ownerId);
  Future<Map<String, dynamic>?> getOwnerById(String ownerId);
}

class PropertyLocalDataSourceImpl implements PropertyLocalDataSource {
  @override
  Future<List<PropertyModel>> getProperties({PropertyFilter? filter}) async {
    final box = HiveService.propertiesBox;
    final List<PropertyModel> results = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final model = PropertyModel.fromMap(raw);
        if (_matchesFilter(model, filter)) {
          results.add(model);
        }
      }
    }
    return results;
  }

  bool _matchesFilter(PropertyModel model, PropertyFilter? filter) {
    if (filter == null) return true;

    // Keyword search
    if (filter.keyword != null && filter.keyword!.trim().isNotEmpty) {
      final query = filter.keyword!.trim().toLowerCase();
      final inName = model.name.toLowerCase().contains(query);
      final inLoc = model.location.toLowerCase().contains(query);
      final inDesc = model.description.toLowerCase().contains(query);
      final inType = model.type.toLowerCase().contains(query);
      final inConfig = model.configuration.toLowerCase().contains(query);

      if (!inName && !inLoc && !inDesc && !inType && !inConfig) {
        return false;
      }
    }

    // Location search
    if (filter.location != null && filter.location!.trim().isNotEmpty) {
      if (!model.location
          .toLowerCase()
          .contains(filter.location!.trim().toLowerCase())) {
        return false;
      }
    }

    // Property Type
    if (filter.type != null) {
      if (model.type.toLowerCase() != filter.type!.label.toLowerCase()) {
        return false;
      }
    }

    // Price Range
    if (filter.priceRange != null) {
      if (model.price < filter.priceRange!.start ||
          model.price > filter.priceRange!.end) {
        return false;
      }
    }

    // Area Range
    if (filter.areaRange != null) {
      if (model.area < filter.areaRange!.start ||
          model.area > filter.areaRange!.end) {
        return false;
      }
    }

    // Status
    if (filter.status != null) {
      if (model.status.toLowerCase() != filter.status!.label.toLowerCase()) {
        return false;
      }
    }

    // Configuration (e.g. 2BHK)
    if (filter.configuration != null &&
        filter.configuration!.trim().isNotEmpty) {
      if (model.configuration.toLowerCase() !=
          filter.configuration!.trim().toLowerCase()) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<PropertyModel?> getPropertyById(String id) async {
    final box = HiveService.propertiesBox;
    final raw = box.get(id);
    if (raw is Map) {
      return PropertyModel.fromMap(raw);
    }
    return null;
  }

  @override
  Future<List<PropertyModel>> getPropertiesByOwnerId(String ownerId) async {
    final box = HiveService.propertiesBox;
    final List<PropertyModel> results = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final model = PropertyModel.fromMap(raw);
        if (model.ownerId == ownerId) {
          results.add(model);
        }
      }
    }
    return results;
  }

  @override
  Future<Map<String, dynamic>?> getOwnerById(String ownerId) async {
    final box = HiveService.ownersBox;
    final raw = box.get(ownerId);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }
}
