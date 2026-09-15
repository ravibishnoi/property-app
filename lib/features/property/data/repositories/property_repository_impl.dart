import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_local_data_source.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyLocalDataSource localDataSource;

  PropertyRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Property>> getProperties({PropertyFilter? filter}) async {
    final models = await localDataSource.getProperties(filter: filter);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Property?> getPropertyById(String id) async {
    final model = await localDataSource.getPropertyById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Property>> getPropertiesByOwnerId(String ownerId) async {
    final models = await localDataSource.getPropertiesByOwnerId(ownerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getOwnerById(String ownerId) async {
    return await localDataSource.getOwnerById(ownerId);
  }
}
