import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/property_local_data_source.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/entities/property.dart';
import '../../domain/entities/property_filter.dart';
import '../../domain/repositories/property_repository.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  return PropertyRepositoryImpl(localDataSource: PropertyLocalDataSourceImpl());
});

class PropertyFilterNotifier extends Notifier<PropertyFilter> {
  @override
  PropertyFilter build() {
    return const PropertyFilter();
  }

  void updateFilter(PropertyFilter filter) {
    state = filter;
  }

  void setKeyword(String? keyword) {
    state = state.copyWith(keyword: keyword, clearKeyword: keyword == null || keyword.isEmpty);
  }

  void setType(dynamic type) {
    state = state.copyWith(type: type, clearType: type == null);
  }

  void resetFilter() {
    state = const PropertyFilter();
  }
}

final propertyFilterProvider =
    NotifierProvider<PropertyFilterNotifier, PropertyFilter>(() {
  return PropertyFilterNotifier();
});

final propertyListProvider = FutureProvider<List<Property>>((ref) async {
  final repo = ref.watch(propertyRepositoryProvider);
  final filter = ref.watch(propertyFilterProvider);
  return await repo.getProperties(filter: filter);
});

class PropertyDetailData {
  final Property property;
  final Map<String, dynamic>? owner;

  PropertyDetailData({required this.property, this.owner});
}

final propertyDetailProvider =
    FutureProvider.family<PropertyDetailData?, String>((ref, id) async {
  final repo = ref.read(propertyRepositoryProvider);
  final property = await repo.getPropertyById(id);
  if (property == null) return null;
  final owner = await repo.getOwnerById(property.ownerId);
  return PropertyDetailData(property: property, owner: owner);
});

final ownerPropertiesProvider =
    FutureProvider.family<List<Property>, String>((ref, ownerId) async {
  final repo = ref.read(propertyRepositoryProvider);
  return await repo.getPropertiesByOwnerId(ownerId);
});
