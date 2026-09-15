import 'package:property_app/core/di/hive_boxes.dart';
import 'package:property_app/core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> saveCurrentUser(UserModel user);
  Future<void> clearCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String sessionKey = '__current_user_session__';

  @override
  Future<UserModel> login(String email, String password) async {
    final box = HiveService.usersBox;
    final normalizedEmail = email.trim().toLowerCase();
    
    for (final key in box.keys) {
      if (key == sessionKey) continue;
      final raw = box.get(key);
      if (raw is Map) {
        final user = UserModel.fromMap(raw);
        if (user.email.trim().toLowerCase() == normalizedEmail && user.password == password.trim()) {
          await saveCurrentUser(user);
          return user;
        }
      }
    }
    throw const AuthFailure('Invalid email or password. Please try again.');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final box = HiveService.usersBox;
    final raw = box.get(sessionKey);
    if (raw is Map) {
      return UserModel.fromMap(raw);
    }
    return null;
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    final box = HiveService.usersBox;
    await box.put(sessionKey, user.toMap());
  }

  @override
  Future<void> clearCurrentUser() async {
    final box = HiveService.usersBox;
    await box.delete(sessionKey);
  }
}
