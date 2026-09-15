import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<AppUser> login(String email, String password) async {
    final model = await localDataSource.login(email, password);
    return model.toEntity();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final model = await localDataSource.getCurrentUser();
    return model?.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearCurrentUser();
  }
}
