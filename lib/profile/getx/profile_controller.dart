// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gutrgoopro/uitls/local_store.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileController extends GetxController {
//   Rx<File?> profileImage = Rx<File?>(null);
  
//   final RxString userName = ''.obs;
//   final RxString userEmail = ''.obs;
//   final RxString userPhone = ''.obs;
//   final RxString userDob = ''.obs;
//   final RxBool isLoggedIn = false.obs; // ✅ ADD THIS

//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController dobController;
  
//   RxBool notificationsEnabled = true.obs;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void onInit() {
//     super.onInit();
//     nameController = TextEditingController();
//     emailController = TextEditingController();
//     phoneController = TextEditingController();
//     dobController = TextEditingController();
    
//     nameController.addListener(() => userName.value = nameController.text);
//     emailController.addListener(() => userEmail.value = emailController.text);
//     phoneController.addListener(() => userPhone.value = phoneController.text);
//     dobController.addListener(() => userDob.value = dobController.text);
    
//     checkLoginStatus(); // ✅ loadUserData ki jagah
//   }

//   // ✅ NEW - sirf ek baar call hoga
//   Future<void> checkLoginStatus() async {
//     bool loggedIn = await LocalStore.isLoggedIn();
//     isLoggedIn.value = loggedIn;
//     if (loggedIn) await loadUserData();
//     print('🔍 Checking login status: $loggedIn');
//   }

//   Future<void> loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final name = prefs.getString('userName') ?? 'User';
//     final email = prefs.getString('userEmail') ?? '';
//     final phone = prefs.getString('userPhone') ?? '';
    
//     nameController.text = name;
//     emailController.text = email;
//     phoneController.text = phone;
    
//     userName.value = name;
//     userEmail.value = email;
//     userPhone.value = phone;
//   }

//   Future<void> saveUserData(String name, String email, String phone) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userName', name);
//     await prefs.setString('userEmail', email);
//     await prefs.setString('userPhone', phone);
    
//     nameController.text = name;
//     emailController.text = email;
//     phoneController.text = phone;
    
//     userName.value = name;
//     userEmail.value = email;
//     userPhone.value = phone;
//   }

//   Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userName');
//     await prefs.remove('userEmail');
//     await prefs.remove('userPhone');
    
//     nameController.text = '';
//     emailController.text = '';
//     phoneController.text = '';
    
//     userName.value = '';
//     userEmail.value = '';
//     userPhone.value = '';
//     isLoggedIn.value = false; // ✅ logout pe false
//   }

//   void toggleNotification(bool val) => notificationsEnabled.value = val;

//   Future<void> pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery, imageQuality: 80);
//     if (pickedFile != null) profileImage.value = File(pickedFile.path);
//   }

//   Future<void> selectDate(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2000),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: Colors.blue,
//               onPrimary: Colors.white,
//               onSurface: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (pickedDate != null) {
//       final formattedDate =
//           "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
//       dobController.text = formattedDate;
//       userDob.value = formattedDate;
//     }
//   }

//   Future<void> saveChanges() async {
//     await saveUserData(
//       nameController.text,
//       emailController.text,
//       phoneController.text,
//     );
//     Get.snackbar(
//       "Success",
//       "Profile updated successfully",
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     dobController.dispose();
//     super.onClose();
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  Rx<File?> profileImage = Rx<File?>(null);

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userDob = ''.obs;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  
  RxBool notificationsEnabled = true.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dobController = TextEditingController();
    
    nameController.addListener(() => userName.value = nameController.text);
    emailController.addListener(() => userEmail.value = emailController.text);
    phoneController.addListener(() => userPhone.value = phoneController.text);
    dobController.addListener(() => userDob.value = dobController.text);
    
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Load saved user data
      final name = prefs.getString('userName') ?? 'User';
      final email = prefs.getString('userEmail') ?? '';
      final phone = prefs.getString('userPhone') ?? '';
      
      nameController.text = name;
      emailController.text = email;
      phoneController.text = phone;
      
      userName.value = name;
      userEmail.value = email;
      userPhone.value = phone;
    } else {
      // Guest user
      nameController.text = '';
      emailController.text = '';
      phoneController.text = '';
      
      userName.value = '';
      userEmail.value = '';
      userPhone.value = '';
    }
  }

  Future<void> saveUserData(String name, String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhone', phone);
    
    nameController.text = name;
    emailController.text = email;
    phoneController.text = phone;
    
    userName.value = name;
    userEmail.value = email;
    userPhone.value = phone;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userPhone');
    
    nameController.text = '';
    emailController.text = '';
    phoneController.text = '';
    
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
  }

  void toggleNotification(bool val) => notificationsEnabled.value = val;

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) profileImage.value = File(pickedFile.path);
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
      dobController.text = formattedDate;
      userDob.value = formattedDate;
    }
  }

  Future<void> saveChanges() async {
    await saveUserData(
      nameController.text,
      emailController.text,
      phoneController.text,
    );
    // Get.snackbar(
    //   "Success",
    //   "Profile updated successfully",
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    // );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}

