// import 'package:shared_preferences/shared_preferences.dart';

// class LocalStore {
//   static const String _isLoggedInKey = 'isLoggedIn';

//   // Save login status
//   static Future<void> setLoggedIn(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isLoggedInKey, value);
//     print('✅ Login status saved: $value');
//   }

//   // Check login status
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final status = prefs.getBool(_isLoggedInKey) ?? false;
//     print('🔍 Checking login status: $status');
//     return status;
//   }

//   // Logout (clear login status)
//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_isLoggedInKey, false);
//     print('🚪 User logged out');
//   }
// }
