import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OtpService {
  static Future<bool> sendOtp({
    required String mobile,
    required String otp,
  }) async {
    final url = Uri.parse(
      "https://web.smscloud.in/api/pushsms?"
      "user=GUTARGOO&"
      "authkey=OBrzm0uM6MvuyR2bnlRSDIzpaF2OZbzO&"
      "type=1&"
      "sender=GTARGO&"
      "mobile=$mobile&" 
      "text=Your%20One%20Time%20Password(OTP)%20is%20$otp%20for%20Gutargoo%2B%20app%20login.%20Do%20not%20share%20it%20with%20any%20one.%20Valid%20till%205%20minutes.www.gutargooplus.com&"  // ✅ Use actual OTP
      "templateid=1707176045271265119&"
      "rpt=1"
    );

    if (kDebugMode) {
      print('Sending OTP to: $mobile');
      print('OTP Code: $otp');
      print('Request URL: $url');
    }

    final response = await http.get(url);

    if (kDebugMode) {
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");
    }

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        return responseData['STATUS'] == 'OK' || 
               responseData['RESPONSE']?['CODE'] == '100';
      } catch (e) {
        print('Error parsing response: $e');
        return false;
      }
    }

    return false;
  }
}

