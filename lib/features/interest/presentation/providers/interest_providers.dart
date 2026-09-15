import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/interest_local_data_source.dart';
import '../../data/repositories/interest_repository_impl.dart';
import '../../domain/entities/interest_submission.dart';
import '../../domain/repositories/interest_repository.dart';
import 'package:property_app/features/property/presentation/providers/property_providers.dart';

final interestRepositoryProvider = Provider<InterestRepository>((ref) {
  return InterestRepositoryImpl(localDataSource: InterestLocalDataSourceImpl());
});

class SubmitInterestNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> submit({
    required String propertyId,
    required String propertyName,
    required String name,
    required String mobile,
    required String email,
    required String message,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(interestRepositoryProvider);
      final submission = InterestSubmission(
        id: 'int_${DateTime.now().millisecondsSinceEpoch}',
        propertyId: propertyId,
        propertyName: propertyName,
        name: name,
        mobile: mobile,
        email: email,
        message: message,
        submittedAt: DateTime.now(),
      );
      await repo.submitInterest(submission);
      state = const AsyncData(null);
      // Invalidate owner interests so owner dashboard gets updated immediately
      ref.invalidate(ownerInterestsProvider);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final submitInterestProvider =
    NotifierProvider<SubmitInterestNotifier, AsyncValue<void>>(() {
  return SubmitInterestNotifier();
});

final ownerInterestsProvider =
    FutureProvider.family<List<InterestSubmission>, String>((ref, ownerId) async {
  final properties = await ref.watch(ownerPropertiesProvider(ownerId).future);
  final propertyIds = properties.map((p) => p.id).toList();
  if (propertyIds.isEmpty) return [];
  
  final repo = ref.watch(interestRepositoryProvider);
  return await repo.getInterestsForProperties(propertyIds);
});
