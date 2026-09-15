import 'package:property_app/core/di/hive_boxes.dart';
import '../models/interest_model.dart';

abstract class InterestLocalDataSource {
  Future<void> submitInterest(InterestModel model);
  Future<List<InterestModel>> getInterestsForProperties(List<String> propertyIds);
}

class InterestLocalDataSourceImpl implements InterestLocalDataSource {
  @override
  Future<void> submitInterest(InterestModel model) async {
    final box = HiveService.interestsBox;
    await box.put(model.id, model.toMap());
  }

  @override
  Future<List<InterestModel>> getInterestsForProperties(List<String> propertyIds) async {
    final box = HiveService.interestsBox;
    final List<InterestModel> results = [];
    final idSet = propertyIds.toSet();

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final model = InterestModel.fromMap(raw);
        if (idSet.contains(model.propertyId)) {
          results.add(model);
        }
      }
    }
    // Sort latest first
    results.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return results;
  }
}
