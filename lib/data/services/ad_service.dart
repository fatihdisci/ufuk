import 'dart:io';
import 'dart:async'; // Moved to top
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class AdService {
  // TEST IDs
  static const String _nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  bool _isInit = false;

  Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await MobileAds.instance.initialize();
    _isInit = true;
    _loadInterstitial(); // Preload one
  }

  /// SAFETY CHECK: Returns true only if it is safe to show ads.
  /// Rules:
  /// 1. Android Only (Web = false)
  /// 2. Data must exist
  /// 3. Not in 'Huzur Zone' [Iftar - 15min, Iftar]
  bool isAdAllowed(DateTime now, Map<String, dynamic>? todayData) {
    if (kIsWeb || !Platform.isAndroid || !_isInit) return false;
    if (todayData == null) return false;

    try {
      final maghribStr = todayData['timings']['Maghrib'].toString().split(' ')[0];
      final iftarTime = _parseTime(now, maghribStr);
      final huzurStart = iftarTime.subtract(const Duration(minutes: 15));

      // Block if in [Iftar - 15, Iftar]
      if (now.isAfter(huzurStart) && now.isBefore(iftarTime)) {
        debugPrint("AdService: Blocked (Huzur Zone)");
        return false;
      }
      
      // Also implicit: if it is actually Iftar time, we might want to allow?
      // Requirement says [Iftar - 15, Iftar] inclusive.
      // After Iftar is fine.
      
      return true;
    } catch (e) {
      debugPrint("AdService: Error checking safety: $e");
      return false; // Fail Closed
    }
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial failed: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitial(BuildContext context, VoidCallback onComplete) {
    if (_interstitialAd == null) {
      onComplete();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial(); // Reload for next time
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitial();
        onComplete();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // Clear usage
  }

  Future<NativeAd?> loadNativeAd() async {
     if (kIsWeb || !Platform.isAndroid) return null;

     final completer = Completer<NativeAd?>();
     
     final ad = NativeAd(
       adUnitId: _nativeAdUnitId,
       factoryId: 'listTile', // Uses default or custom factory if setup
       // For MVP without custom XML factory, we use default template style if available or generic
       // Flutter plugin NativeAd requires either a factoryID (native platform) or nativeTemplateStyle (Dart-only rendering)
       // We will use nativeTemplateStyle for ease of setup without Android XML
       nativeTemplateStyle: NativeTemplateStyle(
         templateType: TemplateType.medium,
         mainBackgroundColor: Colors.transparent,
         callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: Colors.white24,
            style: NativeTemplateFontStyle.bold,
            size: 16.0
         ),
         primaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.bold,
            size: 16.0
         ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white70,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.normal,
            size: 14.0
         ),
       ),
       request: const AdRequest(),
       listener: NativeAdListener(
         onAdLoaded: (ad) {
           completer.complete(ad as NativeAd);
         },
         onAdFailedToLoad: (ad, error) {
           ad.dispose();
           debugPrint('AdService: Native failed: $error');
           completer.complete(null);
         },
       ),
     );
     
     await ad.load();
     return completer.future;
  }
  
  DateTime _parseTime(DateTime now, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
