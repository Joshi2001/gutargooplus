import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/uitls/colors.dart';

class StreamingQualityScreen extends StatefulWidget {
  @override
  _StreamingQualityScreenState createState() => _StreamingQualityScreenState();
}

class _StreamingQualityScreenState extends State<StreamingQualityScreen> {
  String selectedQuality = 'Auto';

  final List<Map<String, String>> qualities = [
    {'value': 'Low',    'subtitle': 'Saves data, lower resolution'},
    {'value': 'Medium', 'subtitle': 'Balanced quality & data'},
    {'value': 'High',   'subtitle': 'Best quality, uses more data'},
    {'value': 'Auto',   'subtitle': 'Adjusts based on connection'},
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF111111),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Streaming Quality',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(color: const Color(0xFF222222), height: 0.5),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFF222222), width: 0.5),
                ),
                child: Column(
                  children: List.generate(qualities.length, (index) {
                    final q = qualities[index];
                    final isSelected = selectedQuality == q['value'];
                    final isLast = index == qualities.length - 1;

                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.vertical(
                              top: index == 0 ? Radius.circular(14.r) : Radius.zero,
                              bottom: isLast ? Radius.circular(14.r) : Radius.zero,
                            ),
                            onTap: () {
                              setState(() => selectedQuality = q['value']!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Streaming quality set to ${q['value']}'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    side: const BorderSide(
                                        color: Color(0xFF333333), width: 0.5),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20.w,
                                    height: 20.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.orange
                                            : const Color(0xFF444444),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10.w,
                                              height: 10.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.orange,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q['value']!,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.orange
                                                : Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          q['subtitle']!,
                                          style: TextStyle(
                                            color: const Color(0xFF666666),
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (q['value'] == 'Auto')
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E1008),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: AppColors.orange.withOpacity(0.27),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        'Recommended',
                                        style: TextStyle(
                                          color: AppColors.orange,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: const Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: Color(0xFF222222)),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Select your preferred streaming quality. Higher quality gives better visuals but uses more data.',
                style: TextStyle(
                  color: const Color(0xFF666666),
                  fontSize: 13.sp,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}