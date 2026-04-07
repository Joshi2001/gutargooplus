import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gutrgoopro/custom/sign_out.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';
import 'package:gutrgoopro/uitls/colors.dart';
import 'package:gutrgoopro/uitls/local_store.dart';

class EditProfileScreen extends StatefulWidget {

  EditProfileScreen({super.key,});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
 @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final mobile = await LocalStore.getMobile();
    controller.userPhone.value = mobile ?? '';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48.r,
                    backgroundColor: const Color(0xFF2A2A2A),
                    child: Icon(
                      Icons.person,
                      size: 48.sp,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(height: 10.h),
                 Obx(() => Text(
  controller.userPhone.value.isNotEmpty
      ? controller.userPhone.value  // ✅ sirf number
      : '—',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13.sp,
                        ),
                      )),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // ── Phone Number Card ──
            Text(
              'Phone Number',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.07),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Flag + code
                  Text(
                    '🇮🇳',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '+91',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 1,
                    height: 20.h,
                    color: Colors.white12,
                  ),
                  SizedBox(width: 12.w),
                  // Phone number
                  Obx(() => Text(
                        controller.userPhone.value.isNotEmpty
                            ? controller.userPhone.value
                            : '—',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  const Spacer(),
                  // Lock icon — non-editable indicator
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16.sp,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                'Phone number cannot be changed',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 11.sp,
                ),
              ),
            ),

            const Spacer(),

            // ── Sign Out Button ──
            GestureDetector(
              onTap: () => showSignOutPopup(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/bottombar/bottom_binding.dart';
// import 'package:gutrgoopro/custom/sign_out.dart';
// import 'package:gutrgoopro/profile/getx/profile_controller.dart';
// import 'package:gutrgoopro/uitls/colors.dart';

// class EditProfileScreen extends StatelessWidget {
//   final ProfileController controller = Get.find<ProfileController>(); // Same instance

//   EditProfileScreen({super.key});
// // final RxBool isLoggedIn = false.obs;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF121212),
//         elevation: 0,
//         leadingWidth: 200,
//         leading: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Get.back(),
//             ),
//             const SizedBox(width: 5),
//             const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18)),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Center(
//               child: Stack(
//                 children: [
//                   Obx(() {
//                     return CircleAvatar(
//                       radius: 60,
//                       backgroundColor: Colors.deepOrange,
//                       backgroundImage: controller.profileImage.value != null
//                           ? FileImage(controller.profileImage.value!)
//                           : null,
//                       child: controller.profileImage.value == null
//                           ? const Icon(Icons.person, size: 60, color: Colors.white)
//                           : null,
//                     );
//                   }),
//                 Positioned(
//       bottom: 0,
//       right: 0,
//       child: GestureDetector(
//     onTap: controller.pickImage,
//     child: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             const Color(0xFFF97316).withOpacity(0.9),
//             const Color(0xFFEF4444).withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: const Color(0xFF121212),
//           width: 3,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFF97316).withOpacity(0.4),
//             blurRadius: 8,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: const Icon(
//         Icons.camera_alt_rounded,
//         size: 20,
//         color: Colors.white,
//       ),
//     ),
//       ),
//     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text('Tap to change photo', style: TextStyle(color: Colors.grey, fontSize: 14)),
//             const SizedBox(height: 32),
//             _buildTextField(label: 'Full Name', controller: controller.nameController, hint: 'Enter your name'),
//             const SizedBox(height: 20),
//             _buildTextField(label: 'Email', controller: controller.emailController, hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
//             const SizedBox(height: 20),
//             _buildTextField(label: 'Phone Number', controller: controller.phoneController, hint: 'Enter phone number', keyboardType: TextInputType.phone),
//             const SizedBox(height: 20),
//             _buildTextField(label: 'Date of Birth', controller: controller.dobController, hint: 'dd/mm/yyyy', readOnly: true, onTap: () => controller.selectDate(context), suffixIcon: Icons.calendar_today),
//             const SizedBox(height: 32),
//          SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//     onPressed: () async {
//       await controller.saveChanges(); 
//       Get.to(() => BottomNavigationScreen());
//     },
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Colors.transparent,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       shadowColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       padding: EdgeInsets.zero,
//     ),
//     child: Ink(
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [
//             Color(0xFFF97316),
//             Color(0xFFEF4444),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         // border: Border.all(
//         //   color: const Color(0xFFF97316).withOpacity(0.5),
//         //   width: 1.5,
//         // ),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: const Color(0xFFF97316).withOpacity(0.4),
//         //     blurRadius: 12,
//         //     offset: const Offset(0, 4),
//         //   ),
//         // ],
//       ),
//       child: Container(
//         alignment: Alignment.center,
//         height: 50,
//         child: const Text(
//           'Save Changes',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//       ),
//     ),
//     SizedBox(height: 10.h,),
//       _menuTile(
//               Icons.logout_rounded,
//               'Sign Out',
//               onTap: () => showSignOutPopup(context), 
//               showBorder: true,
//               color: Colors.red,
//               showContainerBorder: true,
//             ),
    
//           ],
//         ),
//       ),
//       );
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     required String hint,
//     TextInputType? keyboardType,
//     IconData? suffixIcon,
//     bool readOnly = false,
//     VoidCallback? onTap,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           readOnly: readOnly,
//           onTap: onTap,
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: Colors.grey),
//             filled: true,
//             fillColor: const Color(0xFF2A2A2A),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey, size: 20) : null,
//           ),
//         ),
//       ],
//     );
//   }
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
