import 'package:sqflite/sqflite.dart';
import 'package:kiosk/core/database/database_helper.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> login(String emailOrUsername, String password) async {
    try {
      final db = await _dbHelper.database;
      
      // Debug: Check all users
      final allUsers = await db.query('users');
      print('All users in database: ${allUsers.length}');
      for (var user in allUsers) {
        print('User: ${user['username']}, Email: ${user['email']}');
      }
      
      final result = await db.query(
        'users',
        where: '(email = ? OR username = ?) AND password = ?',
        whereArgs: [emailOrUsername, emailOrUsername, password],
        limit: 1,
      );

      print('Login attempt: $emailOrUsername, found: ${result.length}');
      
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    final db = await _dbHelper.database;

    try {
      await db.insert(
        'users',
        {
          'username': username,
          'email': email,
          'password': password,
          'phone': phone ?? '',
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}

