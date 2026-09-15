import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes
    final usersBox = await Hive.openBox<Map>(AppConstants.usersBox);
    final propertiesBox = await Hive.openBox<Map>(AppConstants.propertiesBox);
    final ownersBox = await Hive.openBox<Map>(AppConstants.ownersBox);
    await Hive.openBox<Map>(AppConstants.interestsBox);

    // If properties or users box is empty, seed from db.json
    if (propertiesBox.isEmpty || usersBox.isEmpty) {
      await seedDatabase(usersBox, propertiesBox, ownersBox);
    }
  }

  static Future<void> seedDatabase(
    Box<Map> usersBox,
    Box<Map> propertiesBox,
    Box<Map> ownersBox,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.dbJsonPath);
      final Map<String, dynamic> data = json.decode(jsonString);

      // Seed users
      if (data.containsKey('users')) {
        final List users = data['users'];
        for (final user in users) {
          if (user is Map) {
            await usersBox.put(user['id'], Map<String, dynamic>.from(user));
          }
        }
      }

      // Seed owners
      if (data.containsKey('owners')) {
        final List owners = data['owners'];
        for (final owner in owners) {
          if (owner is Map) {
            await ownersBox.put(owner['id'], Map<String, dynamic>.from(owner));
          }
        }
      }

      // Seed properties
      if (data.containsKey('properties')) {
        final List properties = data['properties'];
        for (final property in properties) {
          if (property is Map) {
            await propertiesBox.put(property['id'], Map<String, dynamic>.from(property));
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error seeding Hive database from assets: $e');
    }
  }

  static Box<Map> get usersBox => Hive.box<Map>(AppConstants.usersBox);
  static Box<Map> get propertiesBox => Hive.box<Map>(AppConstants.propertiesBox);
  static Box<Map> get ownersBox => Hive.box<Map>(AppConstants.ownersBox);
  static Box<Map> get interestsBox => Hive.box<Map>(AppConstants.interestsBox);

  // Helper method to reset/re-seed if needed
  static Future<void> resetToSeed() async {
    await usersBox.clear();
    await propertiesBox.clear();
    await ownersBox.clear();
    await seedDatabase(usersBox, propertiesBox, ownersBox);
  }
}
