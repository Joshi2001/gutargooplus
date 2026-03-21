
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:gutrgoopro/profile/screen/help_faq.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F1419),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,size: 14.r,),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
_buildPolicySection(
  title: '1. Information We Collect',
  content:
      'We collect information you provide directly, such as when you create an account or contact us. This includes name, email, and viewing preferences.',
),
_buildPolicySection(
  title: '2. How We Use Your Information',
  content:
      'We use your information to provide, maintain, and improve our services, send communications, and comply with legal obligations.',
),
_buildPolicySection(
  title: '3. Data Security',
  content:
      'We implement industry-standard security measures to protect your personal information. All data is encrypted during transmission and stored securely.',
),
_buildPolicySection(
  title: '4. Sharing Your Information',
  content:
      'We do not sell your personal information. We may share data with trusted service providers who assist us in operating our platform, under strict confidentiality agreements.',
), 
_buildPolicySection(
  title: '5. Cookies and Tracking',
  content:
      'We use cookies and similar technologies to enhance your experience, remember preferences, and analyze how you use Gutargoo.',
),
_buildPolicySection(
  title: '6. Your Rights',
  content:
      'You have the right to access, update, or delete your personal information. Contact us at Support@Gutargooplus.com to exercise these rights.',
),
_buildPolicySection(
  title: '7. iOS App subscription & Payment',
  content:
      'Gutargoo+ does not offer any paid subscriptions or purchases on iOS. All content available in the iOS version is free to access..',
),
_buildPolicySection(
  title: '8. Contact Us',
  content:
      'For any questions, feedback, or support, feel free to reach out to us anytime at Support@Gutargooplus.com',
),
          SizedBox(height: 24),
          Text(
            'Last Updated: January 2026',
            style: TextStyle(
              color: Color(0xFF6B7690),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF3A4556),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            content,
            style: TextStyle(
              color: Color(0xFF8B92A0),
              fontSize: 8.sp,
              height: 1.4.h,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsOptionsWidget extends StatelessWidget {
  const SettingsOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingOption(
          icon: Icons.help_outline,
          label: 'Help & FAQ',
          onTap: () => Get.to(() => HelpFAQScreen()),
        ),
        _buildSettingOption(
          icon: Icons.security,
          label: 'Privacy Policy',
          onTap: () => Get.to(() => PrivacyPolicyScreen()),
        ),
      ],
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF3A4556),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}