import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser?> getCurrentUser();
  Future<void> logout();
}
