import '../../domain/entities/interest_submission.dart';
import '../../domain/repositories/interest_repository.dart';
import '../datasources/interest_local_data_source.dart';
import '../models/interest_model.dart';

class InterestRepositoryImpl implements InterestRepository {
  final InterestLocalDataSource localDataSource;

  InterestRepositoryImpl({required this.localDataSource});

  @override
  Future<void> submitInterest(InterestSubmission submission) async {
    final model = InterestModel(
      id: submission.id,
      propertyId: submission.propertyId,
      propertyName: submission.propertyName,
      name: submission.name,
      mobile: submission.mobile,
      email: submission.email,
      message: submission.message,
      submittedAt: submission.submittedAt.toIso8601String(),
    );
    await localDataSource.submitInterest(model);
  }

  @override
  Future<List<InterestSubmission>> getInterestsForProperties(
      List<String> propertyIds) async {
    final models =
        await localDataSource.getInterestsForProperties(propertyIds);
    return models.map((m) => m.toEntity()).toList();
  }
}
