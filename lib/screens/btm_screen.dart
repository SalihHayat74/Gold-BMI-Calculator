import 'dart:io';
import 'package:bmicalculator/consolePrintWithColor.dart';
import 'package:bmicalculator/providers/ad_counter_provider.dart';
import 'package:bmicalculator/screens/recent_history.dart';
import 'package:bmicalculator/screens/step_counts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../ad_helper.dart';
import 'charts/chart.dart';
import 'home.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({Key? key});

  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  var _currentIndex = 0;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    loadAd();
    loadIntAd();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }


  /// Loads a native ad.
  void loadAd() {
    nativeAd = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('$NativeAd loaded.');
            setState(() {
              _nativeAdIsLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            debugPrint('$NativeAd failed to load: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          // Required: Choose a template.
            templateType: TemplateType.medium,
            // Optional: Customize the ad's style.
            mainBackgroundColor: Colors.purple,
            cornerRadius: 10.0,
            callToActionTextStyle: NativeTemplateTextStyle(
                textColor: Colors.cyan,
                backgroundColor: Colors.red,
                style: NativeTemplateFontStyle.monospace,
                size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.red,
                backgroundColor: Colors.cyan,
                style: NativeTemplateFontStyle.italic,
                size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.green,
                backgroundColor: Colors.black,
                style: NativeTemplateFontStyle.bold,
                size: 16.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
                textColor: Colors.brown,
                backgroundColor: Colors.amber,
                style: NativeTemplateFontStyle.normal,
                size: 16.0)))
      ..load();
  }

  bool isADLoading=true;
  _loadInterstitialAd() {
    InterstitialAd.load(
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

          setState(() {
            _interstitialAd = ad;
            isADLoading = false;
          });
        },
        onAdFailedToLoad: (err) {

          setState(() {
            isADLoading = false;
          });
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  InterstitialAd? _interstitialAd;

  loadIntAd() async {
    Future.delayed(Duration(seconds: 3), () async {
      await _loadInterstitialAd();
      if (_interstitialAd != null) {
        _interstitialAd!.show();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    var adProvider=Provider.of<AdCounterProvider>(context,listen:false);
    final List<Widget> widgetOptions = [
      HomeScreen(),
      RecentHistoryScreen(),
      LineChartSample2(),
      DailyStepsPage(),
    ];
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        // extendBody: true,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SalomonBottomBar(
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: isADLoading?(i) async{
                await adProvider.updateAdValue();
                printLog("=============>>>> ${adProvider.isAdShown}");
                if(adProvider.isAdShown){
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(
                            child: Text(
                              'Ad is loading...',
                              style: GoogleFonts.robotoSlab(
                                textStyle:
                                Theme.of(context).textTheme.bodyLarge,
                                fontSize: 14,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            )),
                        content: SizedBox(
                          height: 35,
                          width: 35,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                  Future.delayed(Duration(seconds: 2)).then((value) {
                    Get.back();
                    if (_interstitialAd != null) {
                      _interstitialAd!.show();
                      setState(() {
                        isADLoading=true;
                      });

                    } else {
                      setState(() {
                        _currentIndex=i;
                      });
                    }
                  });
                }

                setState(() {
                  _currentIndex=i;
                });


              }:null,
              items: [
                /// Home
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.calculate_outlined,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "Calculator",
                    style: GoogleFonts.robotoSlab(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontSize: 11,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  selectedColor: Color(0xFFA446A4),
                ),

                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "BMI",
                    style: GoogleFonts.robotoSlab(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontSize: 11,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  selectedColor: Color(0xFFA446A4),
                ),
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "Statistics",
                    style: GoogleFonts.robotoSlab(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontSize: 11,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  selectedColor: Color(0xFFA446A4),
                ),
                SalomonBottomBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    "Steps",
                    style: GoogleFonts.robotoSlab(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      fontSize: 11,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  selectedColor: Color(0xFFA446A4),
                ),
              ],
            ),
            // SizedBox(height: 10),
            // _bannerAd != null
            //     ? Align(
            //         alignment: Alignment.center,
            //         child: Container(
            //           width: _bannerAd.size.width.toDouble(),
            //           height: _bannerAd.size.height.toDouble(),
            //           child: AdWidget(
            //             ad: _bannerAd,
            //           ),
            //         ),
            //       )
            //     : Align(
            //         alignment: Alignment.center,
            //         child: Container(
            //             width: Get.width * 0.9,
            //             height: 40,
            //             child: Center(
            //               child: Text(
            //                 "Ad is loading...",
            //                 style: GoogleFonts.robotoSlab(
            //                   textStyle: Theme.of(context).textTheme.bodyLarge,
            //                   fontSize: 14,
            //                   color: Colors.black,
            //                   letterSpacing: 0.5,
            //                 ),
            //               ),
            //             )),
            //       )
          ],
        ),

        body: Center(
          child: widgetOptions.elementAt(_currentIndex),
        ),
      ),
    );
  }
}

NativeAd? nativeAd;
bool _nativeAdIsLoaded = false;

Future<bool> showExitPopup(context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          // height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Do you want to exit?",
                style: TextStyle(),
              ),
              const SizedBox(height: 10),
              // _nativeAdIsLoaded == false
              //     ? ConstrainedBox(
              //         constraints: const BoxConstraints(
              //           minWidth: 320, // minimum recommended width
              //           minHeight: 90, // minimum recommended height
              //           maxWidth: 400,
              //           maxHeight: 200,
              //         ),
              //         child: Center(
              //           child: Text(
              //             'Ad is loading...',
              //             style: GoogleFonts.robotoSlab(
              //               textStyle: Theme.of(context).textTheme.bodyLarge,
              //               fontSize: 14,
              //               fontWeight: FontWeight.normal,
              //               color: Colors.black,
              //               letterSpacing: 0.5,
              //             ),
              //           ),
              //         ),
              //       )
              //     : ConstrainedBox(
              //         constraints: const BoxConstraints(
              //           minWidth: 320, // minimum recommended width
              //           minHeight: 90, // minimum recommended height
              //           maxWidth: 400,
              //           maxHeight: 200,
              //         ),
              //         child: nativeAd!=null?AdWidget(ad: nativeAd):Center(child: CircularProgressIndicator()),
              //       ),
              // const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('yes selected');
                        // _bannerAd.dispose();
                        exit(0);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red.shade800,
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print('no selected');

                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
