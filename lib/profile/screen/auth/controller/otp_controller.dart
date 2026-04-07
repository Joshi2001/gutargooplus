import 'package:get/get.dart';
import 'package:gutrgoopro/profile/screen/auth/service/otp_service.dart';
import 'package:gutrgoopro/uitls/local_store.dart'; // ← add this

class LoginController extends GetxController {
  final OtpService _otpService = OtpService();

  final RxBool isSending = false.obs;
  final RxBool isVerifying = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString phoneNumber = ''.obs;

  // ✅ Add these to store after verify
  final RxString authToken = ''.obs;
  final Rx<Map<String, dynamic>> currentUser = Rx<Map<String, dynamic>>({});

  Future<bool> sendOtp(String phone) async {
    isSending.value = true;
    errorMessage.value = '';
    print('📤 [Controller] sendOtp() → phone: $phone');

    final result = await _otpService.sendOtp(phone);
    isSending.value = false;

    if (result['success'] == true) {
      phoneNumber.value = phone;
      print('✅ [Controller] OTP sent');
      return true;
    } else {
      errorMessage.value = result['message'] ?? 'Something went wrong.';
      print('❌ [Controller] sendOtp failed: ${errorMessage.value}');
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    isVerifying.value = true;
    errorMessage.value = '';
    print('📤 [Controller] verifyOtp() → phone: ${phoneNumber.value} | otp: $otp');

    final result = await _otpService.verifyOtp(phoneNumber.value, otp);
    isVerifying.value = false;

    if (result['success'] == true) {
      // ✅ Save token & user from API response
      final token = result['token'] ?? '';
      final user = result['user'] ?? {};

      authToken.value = token;
      currentUser.value = Map<String, dynamic>.from(user);

      // ✅ Persist token to local storage
      await LocalStore.setToken(token);
      await LocalStore.setMobile(user['mobile'] ?? '');

      print('✅ [Controller] OTP verified | token: $token');
      return true;
    } else {
      errorMessage.value = result['message'] ?? 'OTP verification failed.';
      print('❌ [Controller] verifyOtp failed: ${errorMessage.value}');
      return false;
    }
  }

  Future<bool> resendOtp() async {
    if (phoneNumber.value.isEmpty) return false;
    return await sendOtp(phoneNumber.value);
  }
}