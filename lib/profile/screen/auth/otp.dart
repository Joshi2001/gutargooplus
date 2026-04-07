import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/otv_verifie_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final TextEditingController _phoneController = TextEditingController();
  bool isPhoneValid = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImages = [
    'assets/1.png',
    'assets/2.png',
    'assets/img3.jpeg',
  ];

  // final List<String> _bannerLogos = [
  //   'assets/logo3.png',
  //   'assets/thenetworking.png',
  //   'assets/Alien.png',
  //   'assets/awasaan_logo.png',
  //   'assets/red_logo.png',
  // ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() => isPhoneValid = _phoneController.text.length == 10);
    });
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _startBannerTimer();
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

  @override
  void dispose() {
    _phoneController.dispose();
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF0D0D0D),
        body: Column(
          children: [
            SizedBox(
              height: 530.h,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
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
                          // Bottom gradient
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  // Color(0x990D0D0D),
                                  // Color(0xFF0D0D0D),
                                ],
                                stops: [0.0, 0.5, 0.8, 1.0],
                              ),
                            ),
                          ),
                          // Logo
                          // Positioned(
                          //   bottom: 28.h,
                          //   left: 0,
                          //   right: 0,
                          //   child: Center(
                          //     child: Image.asset(
                          //       _bannerLogos[i],
                          //       height: 44.h,
                          //       fit: BoxFit.contain,
                          //       errorBuilder: (_, __, ___) =>
                          //           const SizedBox.shrink(),
                          //     ),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
        
                  // Top fade
                  // Positioned(
                  //   top: 0,
                  //   left: 0,
                  //   right: 0,
                  //   child: Container(
                  //     height: 80.h,
                  //     decoration: const BoxDecoration(
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         colors: [Color(0xCC0D0D0D), Colors.transparent],
                  //       ),
                  //     ),
                  //   ),
                  // ),
        
                  // Dot indicators
                  Positioned(
                    bottom: 8.h,
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
        
            // ── Bottom Login Section ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login with Mobile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        letterSpacing: 2,
                      ),
                      decoration: InputDecoration(
                        hintText: '10-digit mobile number',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                          letterSpacing: 0,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇮🇳', style: TextStyle(fontSize: 18.sp)),
                              SizedBox(width: 8.w),
                              Text(
                                '+91',
                                style: TextStyle(
                                  color: const Color(0xFFF97316),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 1.w,
                                height: 20.h,
                                color: Colors.white12,
                              ),
                            ],
                          ),
                        ),
                        counterText: '',
                        filled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: const Color(0xFFF97316),
                            width: 1.5.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 18.h,
                        ),
                      ),
                    ),
                  ),
              
                  SizedBox(height: 20.h),
              
                  Obx(() {
                    final isLoading = controller.isSending.value;
                    final isActive = isPhoneValid && !isLoading;
              
                    return SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: isActive
                            ? () async {
                                final phone = _phoneController.text.trim();
                                final success = await controller.sendOtp(
                                  phone,
                                );
                                if (success) {
                                  Get.to(() => OtpVerificationScreen());
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    controller.errorMessage.value,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          disabledBackgroundColor: const Color(0xFF2A2A2A),
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
                                'Send OTP',
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
                  SizedBox(height: 20.h),
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
              
                  // SizedBox(height: 20.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _featurePill(Icons.lock_outline, 'Secure'),
                  //     SizedBox(width: 10.w),
                  //     _featurePill(Icons.flash_on, 'Instant'),
                  //     SizedBox(width: 10.w),
                  //     _featurePill(Icons.verified_outlined, 'Verified'),
                  //   ],
                  // ),
                  SizedBox(height: 10.h),
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
                  SizedBox(height: 5.h),
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
          ],
        ),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: const Color(0xFFF97316), size: 14.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
