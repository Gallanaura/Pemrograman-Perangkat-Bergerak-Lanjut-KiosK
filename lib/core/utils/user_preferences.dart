import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  static Future<void> saveUser(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }
}

