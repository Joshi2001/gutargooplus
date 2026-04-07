import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String _baseUrl = 'http://81.17.100.176';

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    print('📤 [OtpService] sendOtp() called with phone: $phone');
    try {
      final url = Uri.parse('$_baseUrl/api/otp/send');
      final body = jsonEncode({'mobile': phone});

      print('🌐 [OtpService] POST $url');
      print('📦 [OtpService] Request body: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      print('📥 [OtpService] Response status: ${response.statusCode}');
      print('📥 [OtpService] Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {          
          print('✅ [OtpService] OTP sent successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'OTP sent successfully',
          };
        } else {
          print('❌ [OtpService] Send failed: ${data['message']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to send OTP. Try again.',
          };
        }
      } else {
        print('❌ [OtpService] HTTP error: ${response.statusCode}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP. Try again.',
        };
      }
    } catch (e, stackTrace) {
      print('💥 [OtpService] sendOtp() exception: $e');
      print('🔍 [OtpService] StackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
  print('📤 [OtpService] verifyOtp() called — phone: $phone | otp: $otp');
  try {
    final url = Uri.parse('$_baseUrl/api/otp/verify');
    
    // OTP string hi bhejo, int nahi
    final body = jsonEncode({
      'mobile': phone.trim(),
      'otp': otp.trim(),        // trim() — extra spaces remove karo
    });

    print('🌐 [OtpService] POST $url');
    print('📦 [OtpService] Request body: $body');

    final client = http.Client();
    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.headers['Connection'] = 'close'; // 👈 Yeh add karo
      request.body = body;

      final streamedResponse = await client.send(request)
          .timeout(const Duration(seconds: 15));
      
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid OTP. Please try again.',
        };
      }
    } finally {
      client.close(); // 👈 Client properly close karo
    }

  } catch (e, stackTrace) {
    print('💥 [OtpService] verifyOtp() exception: $e');
    print('🔍 [OtpService] StackTrace: $stackTrace');
    return {
      'success': false,
      'message': 'Network error: $e', // 👈 Actual error dikhao temporarily
    };
  }
}
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class OtpService {
//   static Future<bool> sendOtp({
//     required String mobile,
//     required String otp,
//   }) async {
//     final url = Uri.parse(
//       "https://web.smscloud.in/api/pushsms?"
//       "user=GUTARGOO&"
//       "authkey=OBrzm0uM6MvuyR2bnlRSDIzpaF2OZbzO&"
//       "type=1&"
//       "sender=GTARGO&"
//       "mobile=$mobile&"
//       "text=Your%20One%20Time%20Password(OTP)%20is%20$otp%20for%20Gutargoo%2B%20app%20login.%20Do%20not%20share%20it%20with%20any%20one.%20Valid%20till%205%20minutes.www.gutargooplus.com&"  // ✅ Use actual OTP
//       "templateid=1707176045271265119&"
//       "rpt=1"
//     );
//     if (kDebugMode) {
//       print('Sending OTP to: $mobile');
//       print('OTP Code: $otp');
//       print('Request URL: $url');
//     }
//     final response = await http.get(url);

//     if (kDebugMode) {
//       print("STATUS: ${response.statusCode}");
//       print("RESPONSE: ${response.body}");
//     }

//     if (response.statusCode == 200) {
//       try {
//         final responseData = jsonDecode(response.body);
//         return responseData['STATUS'] == 'OK' || 
//                responseData['RESPONSE']?['CODE'] == '100';
//       } catch (e) {
//         print('Error parsing response: $e');
//         return false;
//       }
//     }

//     return false;
//   }
// }

