// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdmobHelper {
//   static String get bannerUnit => 'ca-app-pub-6433207777417679/9496450879';

//   static initialization() {
//     if (MobileAds.instance == null) {
//       MobileAds.instance.initialize();
//     }
//   }

//   static BannerAd getBannerAd() {
//     BannerAd bAd = new BannerAd(
//         size: AdSize(width: 400, height: 200),
//         adUnitId: 'ca-app-pub-6433207777417679/9496450879',
//         listener: BannerAdListener(onAdClosed: (Ad ad) {
//           print("Ad Closed");
//         }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           ad.dispose();
//         }, onAdLoaded: (Ad ad) {
//           print('Ad Loaded');
//         }, onAdOpened: (Ad ad) {
//           print('Ad opened');
//         }),
//         request: AdRequest());
//     return bAd;
//   }
// }
