import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelpFAQScreen extends StatelessWidget {
  const HelpFAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F1419),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & FAQ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildFAQItem(
            question: 'What type of content is available on Gutargoo+?',
            answer:
                'Gutargoo+ offers self-produced movies as well as officially licensed movies available for streaming.',
          ),
          _buildFAQItem(
            question: 'What should I do if I don’t receive the OTP?',
            answer:
                'Please check your network connection and try the “Resend OTP” option. If the issue continues, try again after some time.',
          ),
          // _buildFAQItem(
          //   question: 'Which devices can I use Gutargoo + on?',
          //   answer:
          //       'Gutargoo + is available on iOS, Android. You can stream on up to 4 devices simultaneously.',
          // ),
          _buildFAQItem(
            question: 'How do I contact customer support?',
            answer:
                'You can reach our support team via email at support@Gutargooplus.com.',
          ),
          _buildFAQItem(
            question: 'How can I use Gutargoo+?',
            answer:
                'Download the app, enter your mobile number, verify using OTP, and start streaming.',
          ),
          _buildFAQItem(
            question: 'How can I improve video quality?',
            answer:
                'Go to Player Settings > Video Quality and select your preferred quality. Higher quality requires faster internet.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: Color(0xFF1A2332),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFF3A4556),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        backgroundColor: Color(0xFF1A2332),
        collapsedBackgroundColor: Color(0xFF1A2332),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          question,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white70,
        ),
        collapsedIconColor: Colors.white70,
        iconColor: Colors.white70,
        children: [
          Padding(
            padding:   EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              answer,
              style: TextStyle(
                color: Color(0xFF8B92A0),
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}