
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:gutrgoopro/ad/controller/ad_controller.dart';
import 'package:gutrgoopro/bottombar/bottom_bind.dart';
import 'package:gutrgoopro/navigation/route_observer.dart';
import 'package:gutrgoopro/bottombar/bottom_controller.dart';
import 'package:gutrgoopro/home/getx/home_controller.dart';
import 'package:gutrgoopro/home/getx/videoController.dart';
import 'package:gutrgoopro/profile/getx/download_controller.dart';
import 'package:gutrgoopro/profile/getx/favorites_controller.dart';
import 'package:gutrgoopro/profile/getx/profile_controller.dart';
import 'package:gutrgoopro/profile/screen/auth/controller/otp_controller.dart';
import 'package:gutrgoopro/search.dart/search_controller.dart';
import 'package:gutrgoopro/splash/splash_screen.dart';
import 'package:screen_protector/screen_protector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  // final available = await InAppPurchase.instance.isAvailable();
  // print("billing $available");
    // await MobileAds.instance.initialize(); 
   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white, 
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
   await ScreenProtector.protectDataLeakageOff();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.landscapeRight,
    // DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitDown,
  ]);
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // Get.put(LoginGoogleController());
    Future.delayed(Duration.zero, () async {
    await ScreenProtector.protectDataLeakageOff();
  // Get.put(VastAdController(), permanent: true);
    Get.put(VideoController());
    Get.put(LoginController());
    Get.put(ProfileController());
    Get.put(HomeController());
    BottomBindings();
    Get.lazyPut<SearchControllerX>(() => SearchControllerX(), fenix: true);
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
    Get.put(DownloadsController());
    Get.put(NavigationController(), permanent: true);
  });
}
    

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
  designSize: const Size(375, 812), 
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return GetMaterialApp(
       defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
     builder: (context, child) {
  return child!;
},
      navigatorObservers: [routeObserver],
      home: SplashScreen(),
    );
  },
);
  }
}

