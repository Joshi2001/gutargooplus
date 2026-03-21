// import 'dart:ui';

// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class RewardedInterstitialController extends GetxController {
//   RewardedInterstitialAd? _rewardedInterstitialAd;
//   RxBool isAdLoaded = false.obs;

//   final String adUnitId = "ca-app-pub-8807008985465514/XXXXXXXXXX"; 
//   // Replace with Rewarded Interstitial Ad Unit ID

//   @override
//   void onInit() {
//     super.onInit();
//     loadAd();
//   }

//   void loadAd() {
//     print("🔄 Loading Rewarded Interstitial Ad...");

//     RewardedInterstitialAd.load(
//       adUnitId: adUnitId,
//       request: const AdRequest(),
//       rewardedInterstitialAdLoadCallback:
//           RewardedInterstitialAdLoadCallback(
//         onAdLoaded: (RewardedInterstitialAd ad) {
//           print("✅ Rewarded Interstitial Loaded");
//           _rewardedInterstitialAd = ad;
//           isAdLoaded.value = true;

//           _rewardedInterstitialAd!.fullScreenContentCallback =
//               FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (ad) {
//               ad.dispose();
//               isAdLoaded.value = false;
//               loadAd();
//             },
//             onAdFailedToShowFullScreenContent: (ad, error) {
//               ad.dispose();
//               isAdLoaded.value = false;
//               loadAd();
//             },
//           );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           print("❌ Failed to load: ${error.message}");
//           isAdLoaded.value = false;
//         },
//       ),
//     );
//   }

//   void showAd({required VoidCallback onAdClosed}) {
//     if (_rewardedInterstitialAd != null && isAdLoaded.value) {
//       _rewardedInterstitialAd!.show(
//         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//           print("🎁 User earned reward: ${reward.amount}");
//         },
//       );

//       onAdClosed();
//     } else {
//       print("⚠️ Ad not ready");
//       onAdClosed();
//     }
//   }

//   @override
//   void onClose() {
//     _rewardedInterstitialAd?.dispose();
//     super.onClose();
//   }
// }
