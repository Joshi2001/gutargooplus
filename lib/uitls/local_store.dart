import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {

  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserId = 'userId';
  static const String _keyPhoneNumber = 'phoneNumber';
  static const String _keyGoogleEmail = 'googleEmail';

  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? userId,
    String? phoneNumber,
    String? googleEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);

    if (userId != null) {
      await prefs.setString(_keyUserId, userId);
    }

    if (phoneNumber != null) {
      await prefs.setString(_keyPhoneNumber, phoneNumber);
    }

    if (googleEmail != null) {
      await prefs.setString(_keyGoogleEmail, googleEmail);
    }
  }

 static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('🔍 Checking login status: $loggedIn');
    return loggedIn;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    print('💾 Login status set to: $value');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    print('🚪 User logged out');
    // Clear any other user data if needed
  }
 
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'userId': prefs.getString(_keyUserId),
      'phoneNumber': prefs.getString(_keyPhoneNumber),
      'googleEmail': prefs.getString(_keyGoogleEmail),
    };
  }
  static const String _firstTimeKey = 'is_first_time';
  
static Future<bool> isFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_first_time') ?? true; // default = true (fresh install)
}

static Future<void> setFirstTimeDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_first_time', false);
}
}
