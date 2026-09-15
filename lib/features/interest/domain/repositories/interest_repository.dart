import '../entities/interest_submission.dart';

abstract class InterestRepository {
  Future<void> submitInterest(InterestSubmission submission);
  Future<List<InterestSubmission>> getInterestsForProperties(List<String> propertyIds);
}
