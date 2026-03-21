import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:gutrgoopro/profile/screen/auth/service/otp_service.dart';

class LoginController extends GetxController {
  final isSending = false.obs;
  final isVerifying = false.obs;
  final errorMessage = ''.obs;

  // ======= TEST CONFIG =======
  final String defaultTestPhone = "9999999999"; 
  final String defaultTestOtp = "123456";     

  final phoneNumber = ''.obs;
  final generatedOtp = ''.obs;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Generate OTP
  String _generateOtp(String mobile) {
    if (mobile == defaultTestPhone) {
      return defaultTestOtp;   // 🔹 123456 only for 9999999999
    } else {
      final random = Random();
      return (100000 + random.nextInt(900000)).toString(); // Random for others
    }
  }

  // Send OTP
  Future<bool> sendOtp(String mobile) async {
    if (mobile.isEmpty || mobile.length != 10) {
      errorMessage.value = 'Please enter a valid 10-digit mobile number';
      return false;
    }

    try {
      isSending.value = true;
      errorMessage.value = '';

      final otp = _generateOtp(mobile);
      generatedOtp.value = otp;
      phoneNumber.value = mobile;

      if (kDebugMode) {
        print('🔐 Generated OTP: $otp');
        print('📱 Phone Number: $mobile');
      }

      // 🔹 Send SMS to ALL numbers (including 9999999999)
      final success = await OtpService.sendOtp(
        mobile: mobile,
        otp: otp,
      );

      if (success) {
        if (kDebugMode) {
          print('✅ OTP sent successfully');
        }
        return true;
      } else {
        errorMessage.value = 'Failed to send OTP. Please try again.';
        if (kDebugMode) {
          print('❌ Failed to send OTP');
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
      if (kDebugMode) {
        print('❌ Error sending OTP: $e');
      }
      return false;
    } finally {
      isSending.value = false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String enteredOtp) async {
    if (enteredOtp.isEmpty || enteredOtp.length != 6) {
      errorMessage.value = 'Please enter a valid 6-digit OTP';
      return false;
    }

    try {
      isVerifying.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print('🔍 Verifying OTP...');
        print('Entered: $enteredOtp');
        print('Expected: ${generatedOtp.value}');
      }

      if (enteredOtp == generatedOtp.value) {
        if (kDebugMode) {
          print('✅ OTP verified successfully!');
        }

        await LocalStore.saveLoginState(
          isLoggedIn: true,
          userId: phoneNumber.value,
          phoneNumber: phoneNumber.value,
        );

        if (kDebugMode) {
          print('💾 Login state saved to SharedPreferences');
        }

        return true;
      } else {
        errorMessage.value = 'Invalid OTP. Please try again.';
        if (kDebugMode) {
          print('❌ OTP verification failed');
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Verification failed: $e';
      if (kDebugMode) {
        print('❌ Error verifying OTP: $e');
      }
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (kDebugMode) {
      print('🔄 Resending OTP to ${phoneNumber.value}');
    }
    return await sendOtp(phoneNumber.value);
  }
  Future<void> logout() async {
    await LocalStore.logout();
    phoneNumber.value = '';
    generatedOtp.value = '';
    errorMessage.value = '';
    phoneController.clear();
    otpController.clear();

    if (kDebugMode) {
      print('👋 User logged out');
    }
  }
  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
