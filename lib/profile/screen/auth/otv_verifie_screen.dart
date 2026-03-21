import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/bottombar/bottom_binding.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final LoginController controller = Get.find<LoginController>();
  final TextEditingController pinController = TextEditingController();

  int _remainingTime = 300;
  Timer? _timer;
  bool canResend = false;

  // ── Banner auto-scroll ──
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImages = [
    'assets/3.jpeg',
    'assets/img1.png',
    'assets/img3.png',
    'assets/awasaan_banner.jpg',
    'assets/red_banner.jpg',
  ];

  final List<String> _bannerLogos = [
    'assets/logo3.png',
    'assets/thenetworking.png',
    'assets/Alien.png',
    'assets/awasaan_logo.png',
    'assets/red_logo.png',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startBannerTimer();
     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,     
  ));
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _bannerImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 300;
      canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        setState(() => canResend = true);
      }
    });
  }

  String get _timerText {
    final m = _remainingTime ~/ 60;
    final s = _remainingTime % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerTimer?.cancel();
    _pageController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp(String pin) async {
    final success = await controller.verifyOtp(pin);
    if (success) {
      await LocalStore.setLoggedIn(true);
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(
        () => const BottomNavigationScreen(initialIndex: 0),
        binding: BottomBindings(),
      );
    } else {
      Get.snackbar(
        'Invalid OTP',
        controller.errorMessage.value,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 46.w,
      height: 52.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white12),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: Column(
            children: [
              SizedBox(
                height: 440.h,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      itemCount: _bannerImages.length,
                      itemBuilder: (_, i) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _bannerImages[i],
                              fit: BoxFit.fill,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: const Color(0xFF1A1A1A)),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Color(0x990D0D0D),
                                    Color(0xFF0D0D0D),
                                  ],
                                  stops: [0.0, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 28.h,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Image.asset(
                                  _bannerLogos[i],
                                  height: 44.h,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 80.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xCC0D0D0D),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 10.h,
                      left: 16.w,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 2.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_bannerImages.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: active ? 20.w : 6.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFF97316)
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(() => Text(
                            'Code sent to +91 ${controller.phoneNumber.value}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14.sp,
                            ),
                          )),
                      SizedBox(height: 20.h),
                      Center(
                        child: Pinput(
                          controller: pinController,
                          length: 6,
                          defaultPinTheme: pinTheme,
                          focusedPinTheme: pinTheme.copyDecorationWith(
                            border: Border.all(
                              color: const Color(0xFFF97316),
                              width: 1.5.w,
                            ),
                          ),
                          submittedPinTheme: pinTheme.copyDecorationWith(
                            border: Border.all(
                              color: const Color(0xFFF97316),
                              width: 1.5.w,
                            ),
                          ),
                          showCursor: true,
                          onCompleted: _handleVerifyOtp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: Text(
                          canResend
                              ? 'OTP expired'
                              : 'Expires in $_timerText',
                          style: TextStyle(
                            color: _remainingTime < 60
                                ? Colors.red.shade400
                                : Colors.grey.shade600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Obx(() {
                        final isLoading = controller.isVerifying.value;
                        return SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final pin = pinController.text.trim();
                                    if (pin.length == 6) {
                                      await _handleVerifyOtp(pin);
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Enter complete 6-digit OTP',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              disabledBackgroundColor:
                                  const Color(0xFF2A2A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 22.w,
                                    height: 22.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Verify OTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        );
                      }),
                      // SizedBox(height: 16.h),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Divider(color: Colors.white12, height: 1.h),
                      //     ),
                      //     Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 12.w),
                      //       child: Text(
                      //         'Secure OTP Login',
                      //         style: TextStyle(
                      //           color: Colors.grey.shade600,
                      //           fontSize: 12.sp,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Divider(color: Colors.white12, height: 1.h),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.07)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined,
                                      color: Colors.grey.shade500,
                                      size: 13.sp),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Change Number',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: canResend
                                ? () async {
                                    final success =
                                        await controller.resendOtp();
                                    if (success) {
                                      _startTimer();
                                      pinController.clear();
                                      Get.snackbar(
                                        'OTP Resent',
                                        'New OTP sent successfully',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: canResend
                                    ? const Color(0xFFF97316).withOpacity(0.12)
                                    : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: canResend
                                      ? const Color(0xFFF97316)
                                          .withOpacity(0.3)
                                      : Colors.white.withOpacity(0.07),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh,
                                      color: canResend
                                          ? const Color(0xFFF97316)
                                          : Colors.grey.shade700,
                                      size: 13.sp),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: canResend
                                          ? const Color(0xFFF97316)
                                          : Colors.grey.shade700,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                        GestureDetector(
 onTap: () async {
  final Uri url = Uri.parse('https://gutargooplus.com/');
  try {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('Could not launch $url: $e');
  }
},
  child: Center(
    child: Text(
      'By continuing, you agree to our Terms & Privacy Policy',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 12.sp,
      ),
      textAlign: TextAlign.center,
    ),
  ),
),

                      SizedBox(height: 12.h),

                      Center(
                        child: Image.asset(
                          'assets/white_logo.png',
                          height: 36.h,
                          width: 140.w,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/bottombar/bottom_bind.dart';
// import 'package:gutrgoopro/bottombar/bottom_binding.dart';
// import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
// import 'package:gutrgoopro/uitls/local_store.dart';
// import 'package:pinput/pinput.dart';

// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({super.key});

//   @override
//   State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final LoginController controller = Get.find<LoginController>();
//   final TextEditingController pinController = TextEditingController();

//   int _remainingTime = 300;
//   Timer? _timer;
//   bool canResend = false;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     setState(() {
//       _remainingTime = 300;
//       canResend = false;
//     });
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_remainingTime > 0) {
//         setState(() => _remainingTime--);
//       } else {
//         timer.cancel();
//         setState(() => canResend = true);
//       }
//     });
//   }

//   String get _timerText {
//     int m = _remainingTime ~/ 60;
//     int s = _remainingTime % 60;
//     return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     pinController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleVerifyOtp(String pin) async {
//     final success = await controller.verifyOtp(pin);
//     if (success) {
//       await LocalStore.setLoggedIn(true);
//       await Future.delayed(const Duration(milliseconds: 500));
//       Get.offAll(
//         () => const BottomNavigationScreen(initialIndex: 0),
//         binding: BottomBindings(),
//       );
//     } else {
//       Get.snackbar(
//         'Invalid OTP',
//         controller.errorMessage.value,
//         backgroundColor: Colors.red.shade800,
//         colorText: Colors.white,
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       pinController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pinTheme = PinTheme(
//       width: 52,
//       height: 56,
//       textStyle: const TextStyle(
//         fontSize: 20,
//         color: Colors.white,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFF242424),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.transparent),
//       ),
//     );

//     return WillPopScope(
//       onWillPop: () async {
//         Get.back();
//         return false;
//       },
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           backgroundColor: const Color(0xFF0D0D0D),
//           body: SafeArea(
//             child: Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 40),

//                     Image.asset(
//                       "assets/white_logo.png",
//                       height: 80,
//                       width: 160,
//                       fit: BoxFit.contain,
//                     ),

//                     const SizedBox(height: 40),

//                     Container(
//                       padding: const EdgeInsets.all(28),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1A1A1A),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.08),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Verify OTP',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Obx(() => Text(
//                                 'Code sent to +91 ${controller.phoneNumber.value}',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade500,
//                                   fontSize: 14,
//                                 ),
//                               )),

//                           const SizedBox(height: 32),

//                           // Pin input
//                           Center(
//                             child: Pinput(
//                               controller: pinController,
//                               length: 6,
//                               defaultPinTheme: pinTheme,
//                               focusedPinTheme: pinTheme.copyDecorationWith(
//                                 border: Border.all(
//                                   color: const Color(0xFFF97316),
//                                   width: 1.5,
//                                 ),
//                               ),
//                               submittedPinTheme: pinTheme.copyDecorationWith(
//                                 border: Border.all(
//                                   color: const Color(0xFFF97316),
//                                   width: 1.5,
//                                 ),
//                               ),
//                               showCursor: true,
//                               onCompleted: _handleVerifyOtp,
//                             ),
//                           ),

//                           const SizedBox(height: 12),

//                           // Timer
//                           Center(
//                             child: Text(
//                               canResend
//                                   ? 'OTP expired'
//                                   : 'Expires in $_timerText',
//                               style: TextStyle(
//                                 color: _remainingTime < 60
//                                     ? Colors.red.shade400
//                                     : Colors.grey.shade600,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 28),

//                           // Verify button
//                           Obx(() {
//                             final isLoading = controller.isVerifying.value;
//                             return SizedBox(
//                               width: double.infinity,
//                               height: 52,
//                               child: ElevatedButton(
//                                 onPressed: isLoading
//                                     ? null
//                                     : () async {
//                                         final pin =
//                                             pinController.text.trim();
//                                         if (pin.length == 6) {
//                                           await _handleVerifyOtp(pin);
//                                         } else {
//                                           Get.snackbar(
//                                             'Error',
//                                             'Enter complete 6-digit OTP',
//                                             backgroundColor: Colors.red,
//                                             colorText: Colors.white,
//                                           );
//                                         }
//                                       },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFF97316),
//                                   disabledBackgroundColor:
//                                       const Color(0xFF2A2A2A),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   elevation: 0,
//                                 ),
//                                 child: isLoading
//                                     ? const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : const Text(
//                                         'Verify OTP',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                               ),
//                             );
//                           }),

//                           const SizedBox(height: 16),

//                           // Resend + Change number
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               TextButton(
//                                 onPressed: () => Get.back(),
//                                 child: Text(
//                                   'Change Number',
//                                   style: TextStyle(
//                                     color: Colors.grey.shade500,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: canResend
//                                     ? () async {
//                                         final success =
//                                             await controller.resendOtp();
//                                         if (success) {
//                                           _startTimer();
//                                           pinController.clear();
//                                           Get.snackbar(
//                                             'OTP Resent',
//                                             'New OTP sent successfully',
//                                             backgroundColor: Colors.green,
//                                             colorText: Colors.white,
//                                             snackPosition:
//                                                 SnackPosition.BOTTOM,
//                                           );
//                                         }
//                                       }
//                                     : null,
//                                 child: Text(
//                                   'Resend OTP',
//                                   style: TextStyle(
//                                     color: canResend
//                                         ? const Color(0xFFF97316)
//                                         : Colors.grey.shade700,
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
