import '../entities/property.dart';
import '../entities/property_filter.dart';

abstract class PropertyRepository {
  Future<List<Property>> getProperties({PropertyFilter? filter});
  Future<Property?> getPropertyById(String id);
  Future<List<Property>> getPropertiesByOwnerId(String ownerId);
  Future<Map<String, dynamic>?> getOwnerById(String ownerId);
}
