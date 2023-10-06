



import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_helper.dart';
import '../consolePrintWithColor.dart';

class AdCounterProvider extends ChangeNotifier{
  bool isAdShown=false;
  InterstitialAd? interstitialAd;

  updateAdValue(){
    isAdShown=!isAdShown;
    notifyListeners();
  }


  loadInterstitialAd()async{
    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId!,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
              print('_moveToHome');
            },
          );

        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  loadAd()async{
    await  loadInterstitialAd();
    printLog("**********${interstitialAd!=null}");
    if(interstitialAd!=null){
      if(isAdShown){
        interstitialAd!.show();
      }

      isAdShown=!isAdShown;
      notifyListeners();
    }


  }


}