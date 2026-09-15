import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(localDataSource: AuthLocalDataSourceImpl());
});

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  FutureOr<AppUser?> build() async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(() {
  return AuthNotifier();
});
