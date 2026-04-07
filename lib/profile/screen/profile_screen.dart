import 'package:flutter/material.dart';
import 'package:flutter_chrome_cast/_session_manager/cast_session_manager.dart';
import 'package:flutter_chrome_cast/entities/cast_session.dart';
import 'package:flutter_chrome_cast/enums/connection_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/otp.dart';
import 'package:gutrgoopro/profile/screen/edit_profile.dart';
import 'package:gutrgoopro/profile/screen/downloads_profile.dart';
import 'package:gutrgoopro/profile/screen/favorites_profile.dart';
import 'package:gutrgoopro/profile/screen/help_faq.dart';
import 'package:gutrgoopro/profile/screen/privacy_policy.dart';
import 'package:gutrgoopro/uitls/local_store.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:gutrgoopro/widget/device_mangement.dart';
import 'package:gutrgoopro/widget/parental_controler.dart';
import 'package:gutrgoopro/widget/redeem_code.dart';
import 'package:gutrgoopro/widget/streaming_quality.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final RxBool isLoggedIn = false.obs;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      bool loggedIn = await LocalStore.isLoggedIn();
      isLoggedIn.value = loggedIn;

      if (loggedIn) {
        await controller.loadUserData();
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _profileCard(),

            // SizedBox(height: 24.h),
            _sectionTitle('APP SETTINGS'),

            _menuTile(Icons.person_outline, 'My Account',
                onTap: () => Get.to(() => EditProfileScreen())),

            _menuTile(Icons.bookmark_border, 'Watchlist', onTap: () => Get.to(() => FavoritesScreen())),

            // _menuTile(Icons.history, 'History'),

       _menuTile(Icons.card_giftcard, 'Redeem Code', onTap: () async {
  final token = await LocalStore.getToken() ?? '';
  print('🎟️ Token for redeem: $token');
  RedeemCodeBottomSheet.show(
    context,
    authToken: token, // ✅ Direct LocalStore se
  );
}),

// activateTvTile(context),
//          _menuTile(Icons.devices, 'Device Management', onTap: () {
//   // Get current connected device (if using Google Cast)
//   final connectedDeviceName =
//       GoogleCastSessionManager.instance.currentSession?.sessionID ?? '';

//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => DeviceManagementScreen(
//         connectedDeviceName: connectedDeviceName,
//         deviceType: 'TV', // or dynamically from session if needed
//       ),
//     ),
//   );
// }),

//          _menuTile(Icons.lock, 'Parental Control', onTap: () {
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => ParentalControlScreen()),
//   );
// }),

            SizedBox(height: 24.h),
            _sectionTitle('VIDEO SETTINGS'),

            _menuTile(Icons.download, 'Download Settings',
                onTap: () => Get.to(() => DownloadsScreen())),

          _menuTile(Icons.high_quality, 'Streaming Quality', onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => StreamingQualityScreen()),
  );
}),

            SizedBox(height: 24.h),
            _sectionTitle('SUPPORT'),

            _menuTile(Icons.help_outline, 'Help & FAQ',
                onTap: () => Get.to(() => HelpFAQScreen())),

            _menuTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                onTap: () => Get.to(() => PrivacyPolicyScreen())),

            // SizedBox(height: 30.h),

            // _bottomButtons(),

            SizedBox(height: 20.h),

            Center(
              child: Text(
                'Version: 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
Widget activateTvTile(BuildContext context) {
  return StreamBuilder<GoogleCastSession?>(
    stream: GoogleCastSessionManager.instance.currentSessionStream,
    builder: (context, snapshot) {
      final connected =
          GoogleCastSessionManager.instance.connectionState ==
              GoogleCastConnectState.connected;

      return _menuTile(
        Icons.tv,
        'Activate TV',
        onTap: () {
          if (connected) {
            // Connected → show bottom sheet
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Casting Active',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        GoogleCastSessionManager.instance
                            .endSessionAndStopCasting();
                        Navigator.pop(context);
                      },
                      child: Text('Stop Casting'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Not connected → open cast dialog
            GoogleCastSessionManager.instance.endSession();
          }
        },
      
       
      );
    },
  );
}
  // ================= PROFILE CARD =================

  // Widget _profileCard() {
  //   return Container(
  //     padding: EdgeInsets.all(16.sp),
  //     decoration: _boxDecoration(),
  //     child: Row(
  //       children: [
  //         Obx(() => CircleAvatar(
  //               radius: 30.r,
  //               backgroundColor: AppColors.orangedark,
  //               backgroundImage: controller.profileImage.value != null
  //                   ? FileImage(controller.profileImage.value!)
  //                   : null,
  //               child: controller.profileImage.value == null
  //                   ? Icon(Icons.person, color: Colors.white)
  //                   : null,
  //             )),
  //         SizedBox(width: 12.w),

  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Obx(() => Text(
  //                     isLoggedIn.value
  //                         ? controller.userName.value
  //                         : 'Guest User',
  //                     style: TextStyle(
  //                         color: Colors.white, fontWeight: FontWeight.bold),
  //                   )),
  //               SizedBox(height: 4.h),
  //               Obx(() => Text(
  //                     isLoggedIn.value
  //                         ? controller.userEmail.value
  //                         : 'Please sign in',
  //                     style: TextStyle(color: Colors.grey),
  //                   )),
  //             ],
  //           ),
  //         ),

  //         /// SIGN IN BUTTON
  //         Obx(() => !isLoggedIn.value
  //             ? GestureDetector(
  //                 onTap: () async {
  //                   final result =
  //                       await Get.to(() => const PhoneLoginScreen());
  //                   if (result == true) {
  //                     await _checkLoginStatus();
  //                   }
  //                 },
  //                 child: Container(
  //                   padding: EdgeInsets.symmetric(
  //                       horizontal: 14.w, vertical: 6.h),
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [Color(0xFFF97316), Color(0xFFEF4444)],
  //                     ),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: Text('Sign In',
  //                       style: TextStyle(color: Colors.white)),
  //                 ),
  //               )
  //             : SizedBox())
  //       ],
  //     ),
  //   );
  // }

  // ================= MENU TILE =================

  Widget _menuTile(IconData icon, String title,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios,
          color: Colors.white, size: 16),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  // ================= BOTTOM BUTTONS =================

  // Widget _bottomButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _bottomItem(Icons.share, 'Share'),
  //       _bottomItem(Icons.star_border, 'Rate Us'),
  //       _bottomItem(Icons.support_agent, 'Support'),
  //       // _bottomItem(Icons.logout, 'Logout', onTap: () async {
  //       //   await controller.clearUserData();
  //       //   isLoggedIn.value = false;
  //       // }),
  //     ],
  //   );
  // }

  Widget _bottomItem(IconData icon, String title,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white))
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Color(0xFF121212),
      borderRadius: BorderRadius.circular(16),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/bottombar/bottom_controller.dart';
// import 'package:gutrgoopro/custom/sign_out.dart';
// import 'package:gutrgoopro/profile/getx/profile_controller.dart';
// import 'package:gutrgoopro/profile/screen/auth/otp.dart';
// import 'package:gutrgoopro/uitls/local_store.dart';
// import 'package:gutrgoopro/profile/screen/downloads_profile.dart';
// import 'package:gutrgoopro/profile/screen/edit_profile.dart';
// import 'package:gutrgoopro/profile/screen/help_faq.dart';
// import 'package:gutrgoopro/profile/screen/privacy_policy.dart';
// import 'package:gutrgoopro/uitls/colors.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//  final ProfileController controller = Get.find<ProfileController>();
//   final RxBool isLoggedIn = false.obs;
// bool _isChecking = false; 
//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }


//  Future<void> _checkLoginStatus() async {
//   if (_isChecking) return;  
//   _isChecking = true;
  
//   try {
//     bool loggedIn = await LocalStore.isLoggedIn();
//     isLoggedIn.value = loggedIn;
    
//     if (loggedIn) {
//       await controller.loadUserData();
//     }
    
//     print('🔍 Profile login status: $loggedIn');
//   } catch (e) {
//     print('❌ Error checking login status: $e');
//     isLoggedIn.value = false;
//   } finally {
//     _isChecking = false;
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return  PopScope(
    
//   canPop: true,
 
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           leading: GestureDetector(
//              onTap: () => Get.find<NavigationController>().changeTab(0),
//             child: Icon(Icons.arrow_back,size: 20.sp,color: Colors.white,)),
//           title: Text('Profile', style: TextStyle(color: Colors.white, fontSize: 20.sp)),
//         ),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.all(16.sp),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _profileCard(),
//               // Subscription Button
//               // _menuTile(
//               //   FontAwesomeIcons.crown,
//               //   'Subscription',
//               //   onTap: () => Get.to(
//               //     () => SubscriptionScreen(),
//               //     binding: SubscriptionBinding(),
//               //   ),
//               //   showBorder: true,
//               //   color: AppColors.orange,
//               //   showContainerBorder: true,
//               // ),
              
//               SizedBox(height: 24.h),
//               _sectionTitle('ACCOUNT'),
//               _menuTile(
//                 Icons.person_outline,
//                 'Edit Profile',
//                 onTap: () => Get.to(() => EditProfileScreen()),
//               ),
//               // _menuTile(
//               //   Icons.payment,
//               //   'Payment Methods',
//               //   onTap: () => Get.to(() => PaymentMethodsScreen()),
//               // ),
//               // SizedBox(height: 24.h),
//               // _sectionTitle('ACTIVITY'),
//               // _menuTile(
//               //   Icons.history,
//               //   'Watch History',
//               //   onTap: () => Get.to(() => HistoryScreen(), binding: HistoryBinding()),
//               // ),
//               _menuTile(
//                 Icons.download,
//                 'Downloads',
//                 onTap: () => Get.to(() => DownloadsScreen()),
//               ),
//               // _menuTile(
//               //   Icons.star_border,
//               //   'Favorites',
//               //   onTap: () => Get.to(() => FavoritesScreen(fromProfile: true))
//               // ),
//               SizedBox(height: 14.h),
//               // _sectionTitle('PREFERENCES'),
//               // _notificationTile()
//               supportSection(controller),
              
//               // Sign Out Button (Similar to Subscription)
             
              
//               SizedBox(height: 24.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//  Widget _profileCard() {
//   return Container(
//     height: 80.h,
//     padding: EdgeInsets.all(16.sp),
//     decoration: _boxDecoration(),
//     child: Row(
//       children: [
//         // Profile Image - Obx mein wrap karo
//         Obx(() => Container(
//           width: 68.r,
//           height: 68.r,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: AppColors.primaryGradient,
//           ),
//           child: Center(
//             child: Container(
//               width: 60.r,
//               height: 60.r,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.orangedark,
//                 image: controller.profileImage.value != null
//                     ? DecorationImage(
//                         image: FileImage(controller.profileImage.value!),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: controller.profileImage.value == null
//                   ? Icon(Icons.person, color: Colors.white, size: 30.sp)
//                   : null,
//             ),
//           ),
//         )),
//         SizedBox(width: 12.w),
        
//         // Name and Email
//         Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Obx(() => Text(
//                     isLoggedIn.value
//                         ? (controller.userName.value.isEmpty
//                             ? 'User'
//                             : controller.userName.value)
//                         : 'Guest User',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )),
//               SizedBox(height: 4.h),
//               Obx(() => Text(
//                     isLoggedIn.value
//                         ? (controller.userEmail.value.isEmpty
//                             ? 'No email'
//                             : controller.userEmail.value)
//                         : 'Please sign in to continue',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                   )),
//             ],
//           ),
//         ),
        
//         // Sign In Button (Only shown when logged out)
//         Obx(() => !isLoggedIn.value
//             ? GestureDetector(
//                 onTap: () async {
//                   final result = await Get.to(() => const PhoneLoginScreen());
//                   if (result == true) {
//                     await _checkLoginStatus();
//                     if (mounted) setState(() {});
//                   }
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10.r),
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFF97316), Color(0xFFEF4444)],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                     child: Text(
//                       'Sign In',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             : const SizedBox.shrink()),
//       ],
//     ),
//   );
// }

//  Widget _menuTile(
//   IconData icon,
//   String title, {
//   Color? color,
//   VoidCallback? onTap,
//   bool showBorder = false,
//   bool showContainerBorder = false,
// }) {
//   final listTile = GestureDetector(
//     onTap: onTap ?? () {},
//     child: ListTile(
//       leading: showBorder
//           ? Container(
//               padding: EdgeInsets.all(8.r),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     (color ?? AppColors.orange).withOpacity(0.3),
//                     (color ?? AppColors.orange).withOpacity(0.1),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Icon(icon, color: color ?? Colors.white, size: 20.sp),
//             )
//           : Icon(icon, color: color ?? Colors.white, size: 20.sp),
//       title: Text(
//         title,
//         style: TextStyle(color: color ?? Colors.white, fontSize: 14.sp),
//       ),
//       trailing: showContainerBorder
//           ? null
//           : Icon(
//               Icons.arrow_forward_ios,
//               size: 16.sp,
//               color: Colors.white,
//             ),
//     ),
//   );

//   if (showContainerBorder) {
//     return Container(
//       margin: EdgeInsets.only(top: 8.h),
//       decoration: BoxDecoration(
//         color: const Color(0xFF121212),
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: color ?? AppColors.orange),
//       ),
//       child: listTile,
//     );
//   }

//   return listTile;
// }

//   Widget _notificationTile() {
//     return Container(
//       decoration: _boxDecoration(),
//       child: Obx(
//         () => SwitchListTile(
//           title: Text(
//             'Notifications',
//             style: TextStyle(color: Colors.white, fontSize: 12.sp),
//           ),
//           value: controller.notificationsEnabled.value,
//           onChanged: controller.toggleNotification,
//           activeThumbColor: AppColors.orange,
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Colors.grey,
//           fontSize: 12.sp,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }

//   BoxDecoration _boxDecoration() {
//     return BoxDecoration(
//       color: const Color(0xFF121212),
//       borderRadius: BorderRadius.circular(16.r),
//     );
//   }
// }

// Widget supportSection(ProfileController controller) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       SizedBox(height: 14.h),
//       Text(
//         'SUPPORT',
//         style: TextStyle(color: Colors.grey, fontSize: 12.sp, letterSpacing: 1.2),
//       ),
//       SizedBox(height: 8.h),
//       Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF121212),
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         child: Column(
//           children: [
//             _supportTile(
//               icon: Icons.help_outline,
//               title: 'Help & FAQ',
//               onTap: () {
//                 Get.to(() => HelpFAQScreen());
//               },
//             ),
//             _divider(),
//             _supportTile(
//               icon: Icons.privacy_tip_outlined,
//               title: 'Privacy Policy',
//               onTap: () {
//                 Get.to(() => PrivacyPolicyScreen());
//               },
//             ),
//           ],
//         ),
//       ),
//       SizedBox(height: 24.h),
//       Center(
//         child: Text(
//           'Gutargoo+ v1.0.0',
//           style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//         ),
//       ),
//       SizedBox(height: 24.h),
//     ],
//   );
// }

// Widget _supportTile({
//   required IconData icon,
//   required String title,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: ListTile(
//       leading: Icon(icon, color: Colors.grey, size: 16.sp),
//       title: Text(title, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
//     ),
//   );
// }

// Widget _divider() {
//   return Divider(height: 1.h, thickness: 0.5, color: Colors.white10);
// }
