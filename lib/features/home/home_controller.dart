import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/data/repository/prayer_repository.dart';
import 'package:ufuk/data/repository/content_repository.dart';
import 'package:ufuk/data/services/share_service.dart';
import 'package:ufuk/data/services/location_preferences.dart';
import 'package:ufuk/domain/engine/logic_engine.dart';
import 'package:ufuk/domain/engine/context_engine.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ufuk/data/services/ad_service.dart';
import 'package:ufuk/data/services/audio_service.dart';
import 'package:ufuk/data/services/ai_content_service.dart';

// View Models
class HeroViewModel {
  final String timeString;
  final String nextEventLabel;
  final String nextTime;
  
  HeroViewModel(this.timeString, this.nextEventLabel, {this.nextTime = ''});
}

class PrayerTimeDisplay {
  final String name;
  final String time;
  final bool isNext;

  PrayerTimeDisplay(this.name, this.time, {this.isNext = false});
}

enum HomeStatus { loading, online, offline, error }

class HomeController with WidgetsBindingObserver {
  final PrayerRepository _prayerRepo = PrayerRepository();
  final ContentRepository _contentRepo = ContentRepository();
  final LocationPreferences locationPrefs = LocationPreferences();

  final ShareService _shareService = ShareService();
  final AdService _adService = AdService();
  
  final ValueNotifier<bool> isSharingNotifier = ValueNotifier(false);
  final ValueNotifier<NativeAd?> nativeAdNotifier = ValueNotifier(null); // NEW

  final ValueNotifier<String?> themeNotifier = ValueNotifier(null); // Theme State
  final ValueNotifier<bool> isRamadanNotifier = ValueNotifier(false); // NEW
  final ValueNotifier<String?> contextSentenceNotifier = ValueNotifier(null); // NEW
  final ValueNotifier<String?> currentPrayerNotifier = ValueNotifier(null);
  final ValueNotifier<SelectedLocation?> locationNotifier = ValueNotifier(null);

  // State
  final ValueNotifier<TimeSegment> segmentNotifier = ValueNotifier(TimeSegment.morning);
  final ValueNotifier<HeroViewModel> heroNotifier = ValueNotifier(HeroViewModel('--:--:--', 'Yükleniyor...'));
  final ValueNotifier<List<PrayerTimeDisplay>> timesNotifier = ValueNotifier([]);
  final ValueNotifier<Map<String, DailyContent>> contentNotifier = ValueNotifier({});
  final ValueNotifier<String?> aiSummaryNotifier = ValueNotifier(null);
  final ValueNotifier<HomeStatus> statusNotifier = ValueNotifier(HomeStatus.loading);

  Timer? _ticker;
  Map<String, dynamic>? _todayData;

  Future<void> init() async {
    try {
      await _prayerRepo.init();
      await locationPrefs.init();
      await AudioService().init();
      await AiContentService().init();
      WidgetsBinding.instance.addObserver(this);
      
      // Ads Init (Fire and forget, safe per platform check inside service)
      _adService.init().then((_) => _loadNativeAd());

      // Get saved location
      final location = await locationPrefs.getSelectedLocation();
      locationNotifier.value = location;

      await _loadDataForLocation(location);
    } catch (e) {
      statusNotifier.value = HomeStatus.error;
      print("Home Init Error: $e");
    }
  }

  Future<void> _loadDataForLocation(SelectedLocation location) async {
    statusNotifier.value = HomeStatus.loading;
    
    try {
      final now = DateTime.now();
      
      // Determine Theme (Deterministic)
      final theme = ContextEngine.getDailyTheme(now);
      themeNotifier.value = theme;
      
      // Load Static Content (with Theme)
      final content = await _contentRepo.getDailyContent(now, theme: theme);
      contentNotifier.value = content;

      // Load Prayer Data using selected location
      final monthData = await _prayerRepo.getPrayerTimesForMonth(
        now.year, 
        now.month, 
        lat: location.lat, 
        lng: location.lng,
      );
      
      // Find today's data
      _todayData = _findToday(monthData, now);

      if (_todayData != null) {
        statusNotifier.value = HomeStatus.online;
        _updateTimesList(_todayData!);
        
        // Ramadan Detection
        final isRamadan = ContextEngine.checkRamadan(_todayData!);
        isRamadanNotifier.value = isRamadan;
        
        // Context Sentence
        contextSentenceNotifier.value = isRamadan 
            ? "Huzur vaktine yaklaşıyoruz." 
            : "Günün ritmini sakin tut.";
        
        
        _startTimer();

        // Load AI Summary (Fire and forget, non-blocking)
        _loadAiSummary();
      } else {
         statusNotifier.value = HomeStatus.error;
         heroNotifier.value = HeroViewModel('--:--:--', 'Veri Bulunamadı');
      }

    } catch (e) {
      statusNotifier.value = HomeStatus.error;
      print("Home Init Error: $e");
    }
  }

  /// Called when user selects a new location
  Future<void> onLocationChanged(SelectedLocation newLocation) async {
    // Save to preferences
    await locationPrefs.saveSelectedLocation(newLocation);
    locationNotifier.value = newLocation;
    
    // Stop existing timer
    _ticker?.cancel();
    
    // Reload data for new location
    await _loadDataForLocation(newLocation);
  }
  
  Future<void> _loadNativeAd() async {
     final ad = await _adService.loadNativeAd();
     if (ad != null) {
        // Initial check
        if (_adService.isAdAllowed(DateTime.now(), _todayData)) {
           nativeAdNotifier.value = ad;
        }
     }
  }

  Future<void> _loadAiSummary() async {
    try {
      final summary = await AiContentService().getDailySummary(
        date: DateTime.now(),
        segment: segmentNotifier.value, 
        location: locationNotifier.value,
      );
      aiSummaryNotifier.value = summary;
    } catch (e) {
      print("Home Controller AI Load Error: $e");
    }
  }

  void _startTimer() {
    // Immediate Update
    _onTick();
    
    // Tick every second for Countdown
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void _onTick() {
    if (_todayData == null) return;
    
    final now = DateTime.now();

    // 1. Hero Update (Fast)
    final nextEvent = CountdownEngine.resolveNextEvent(now, _todayData!);
    
    // CONTEXT OVERRIDE: Check Ramadan Label
    final isRamadan = ContextEngine.checkRamadan(_todayData!);
    final ramadanLabel = ContextEngine.getRamadanLabel(isRamadan, now, _todayData!);
    
    final finalLabel = ramadanLabel ?? nextEvent.label;
    
    // Update current prayer for timeline highlight
    currentPrayerNotifier.value = _mapLabelToPrayerName(nextEvent.label);

    final duration = nextEvent.remaining;
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    
    heroNotifier.value = HeroViewModel('$h:$m:$s', finalLabel);

    // 2. Segment Update
    if (now.second % 60 == 0) {
       final seg = AtmosphereEngine.resolveSegment(now, _todayData!);
       if (segmentNotifier.value != seg) {
         segmentNotifier.value = seg;
       }
       
       // 3. Ad Safety Check (Every minute)
       // If in Huzur zone, hide ad. If out, show (if loaded).
       // Note: implementation assumes we strictly follow isAdAllowed.
       // If we have an ad loaded but it's not allowed, set notifier to null? 
       // Or keep it but UI hides it? Cleaner to set notifier to null or have a separate bool.
       // Let's reload/hide via notifier for simplicity.
       // Ideally we don't dispose the ad, just hide it. 
       // But GlassCarousel builds based on list.
       // Let's keep it simple: if safe, show. If unsafe, hide.
       // For this phase, we won't implement complex "hide but keep loaded".
       // We'll just rely on _adService.loadNativeAd() being efficient or caching inside service?
       // The service logic created above does NOT cache the native ad after load.
       // So we should keep reference in controller.
       
       // Better logic:
       // bool isSafe = _adService.isAdAllowed(now, _todayData);
       // if (!isSafe && nativeAdNotifier.value != null) nativeAdNotifier.value = null; 
       // if (isSafe && nativeAdNotifier.value == null) _loadNativeAd();
       
       // But _loadNativeAd is async. Let's act conservatively.
       // If currently showing ad and becomes unsafe -> Hide.
       // We won't aggressively reload for now to avoid flicker, just hide if unsafe.
       final isSafe = _adService.isAdAllowed(now, _todayData);
       if (!isSafe && nativeAdNotifier.value != null) {
          // Hide it
          nativeAdNotifier.value = null;
       } 
       // If safe and null, we could try to reload? 
       // For MVP, enable one-shot load at start. If blocked at start, it never loads?
       // Let's allow retry if null and safe.
       if (isSafe && nativeAdNotifier.value == null) {
          _loadNativeAd();
       }
    }
  }

  void dispose() {
    nativeAdNotifier.value?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  bool _wasPlayingBeforeBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (AudioService().isPlaying) {
        _wasPlayingBeforeBackground = true;
        AudioService().pause();
      } else {
        _wasPlayingBeforeBackground = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforeBackground) {
        AudioService().resume();
      }
    }
  }
  
  Map<String, dynamic>? _findToday(List<dynamic> monthData, DateTime now) {
    // Aladhan date format in 'date' -> 'gregorian' -> 'date' is "DD-MM-YYYY"
    final target = "${now.day.toString().padLeft(2,'0')}-${now.month.toString().padLeft(2,'0')}-${now.year}";
    
    try {
      final raw = monthData.firstWhere((d) => d['date']['gregorian']['date'] == target);
      return Map<String, dynamic>.from(raw);
    } catch (e) {
      if (monthData.length >= now.day) {
        return Map<String, dynamic>.from(monthData[now.day - 1]);
      }
      return null;
    }
  }

  void _updateTimesList(Map<String, dynamic> data) {
    final t = data['timings'];
    if (t == null) return;

    // Convert "HH:mm (EET)" to just "HH:mm"
    String cl(String s) => s.split(' ')[0];

    timesNotifier.value = [
      PrayerTimeDisplay('İmsak', cl(t['Imsak'])),
      PrayerTimeDisplay('Güneş', cl(t['Sunrise'])),
      PrayerTimeDisplay('Öğle', cl(t['Dhuhr'])),
      PrayerTimeDisplay('İkindi', cl(t['Asr'])),
      PrayerTimeDisplay('Akşam', cl(t['Maghrib'])),
      PrayerTimeDisplay('Yatsı', cl(t['Isha'])),
    ];
  }
  
  String? _mapLabelToPrayerName(String label) {
    // Map countdown labels to prayer names for timeline highlighting
    const mapping = {
      'İmsaka Kalan': 'İmsak',
      'Sahura Kalan': 'İmsak',
      'Güneşe Kalan': 'Güneş',
      'Öğleye Kalan': 'Öğle',
      'İkindiye Kalan': 'İkindi',
      'Akşama Kalan': 'Akşam',
      'İftara Kalan': 'Akşam',
      'Yatsıya Kalan': 'Yatsı',
    };
    return mapping[label];
  }

  Future<void> share(BuildContext context, DailyContent item) async {
    print("HomeController: Share Triggered");
    
    // Web Check
    if (kIsWeb) {
      print("HomeController: Share blocked on Web");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Web'de paylaşım desteklenmiyor. Android/iOS'ta deneyin."),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    if (isSharingNotifier.value) {
      print("HomeController: Ignored (Already Sharing)");
      return;
    }
    
    isSharingNotifier.value = true;
    
    try {
       // Check Ad Safety before showing Ad
       if (_adService.isAdAllowed(DateTime.now(), _todayData)) {
          print("HomeController: Showing Interstitial Ad");
          _adService.showInterstitial(context, () async {
             // Continue to share after ad logic (dismissed or failed)
             await _executeShare(context, item);
          });
       } else {
          print("HomeController: Ad Blocked/Unsafe, sharing directly");
          await _executeShare(context, item);
       }
    } catch (e) {
       print("HomeController: Share Flow Error: $e");
       // Fallback to share just in case
       await _executeShare(context, item);
    }
  }
  
  Future<void> _executeShare(BuildContext context, DailyContent item) async {
      try {
        print("HomeController: Delegate to ShareService");
        await _shareService.shareContent(context, item, segmentNotifier.value);
      } catch (e) {
        print("HomeController: Share Failed: $e");
      } finally {
        isSharingNotifier.value = false;
        print("HomeController: Share Lock Released");
      }
  }

  Future<void> shareAiContent(BuildContext context, String aiText) async {
    final tempContent = DailyContent(
      source: "UFUK AI",
      text: aiText,
    );
    await share(context, tempContent);
  }
}

