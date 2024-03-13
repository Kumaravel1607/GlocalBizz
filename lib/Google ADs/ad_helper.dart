import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6433207777417679/9496450879';
    } else if (Platform.isIOS) {
      return '--';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return 'ca-app-pub-3940256099942544/7049598008';
  //   } else if (Platform.isIOS) {
  //     return 'ca-app-pub-3940256099942544/3964253750';
  //   } else {
  //     throw new UnsupportedError('Unsupported platform');
  //   }
  // }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return 'ca-app-pub-3940256099942544/8673189370';
  //   } else if (Platform.isIOS) {
  //     return 'ca-app-pub-3940256099942544/7552160883';
  //   } else {
  //     throw new UnsupportedError('Unsupported platform');
  //   }
  // }
}
