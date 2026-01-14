import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/core/config/api_config.dart';
import 'package:ufuk/data/services/location_preferences.dart';

class AiContentService {
  static final AiContentService _instance = AiContentService._internal();
  factory AiContentService() => _instance;
  AiContentService._internal();

  static const String _boxName = 'ufuk_ai_cache';

  Future<void> init() async {
    // Ensure Hive is ready (Hive.initFlutter called in main, just open box here)
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Future<String> getDailySummary({
    required DateTime date,
    required TimeSegment segment,
    required SelectedLocation? location,
  }) async {
    try {
      final box = Hive.box(_boxName);
      final key = 'ai_summary_${date.year}_${date.month}_${date.day}';

      // 1. Check Cache
      if (box.containsKey(key)) {
        final cached = box.get(key);
        if (cached != null && cached is String && cached.isNotEmpty) {
          return cached;
        }
      }

      // 2. Check API Key
      if (!ApiConfig.hasGeminiKey) {
        return _getOfflineFallback(segment);
      }

      // 3. Generate content via Gemini
      final locationName = location?.displayName ?? "İstanbul";
      final segmentName = _getSegmentNameTr(segment);
      
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', // Gemini 2.5 Flash
        apiKey: ApiConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.9, // Creative
          topK: 40,
        ),
      );

      final seed = DateTime.now().millisecondsSinceEpoch;
      print("DEBUG: Fetching NEW wisdom for date: ${date.toIso8601String()} (Seed: $seed)");

      final prompt = '''
Sen "UFUK" adında bilge, minimalist bir manevi rehbersin.
Kullanıcının bulunduğu konumda vakit: $segmentName.
Kullanıcı için RUHA DOKUNAN, kısa, huzur verici bir selamlama cümlesi yaz.
Kurallar:
1. Sadece TEK BİR cümle olsun.
2. Maksimum 30 kelime.
3. Mevlana veya Yunus Emre üslubunda ama modern ve sade olsun.
4. Asla emoji kullanma.
5. Her seferinde farklı perspektiflerden bak, özgün ve yaratıcı bir cümle kur. Bir önceki cümlelerini tekrar etme.
6. Cevap Türkçe olsun.
Bağlam ID: $seed
''';
      print("DEBUG: Gemini Prompt used: $prompt");

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      final text = response.text?.trim() ?? _getOfflineFallback(segment);

      // 4. Cache and Return
      if (text.isNotEmpty) {
        await box.put(key, text);
      }
      
      return text;

    } catch (e) {
      print("AiContentService Error: $e");
      return _getOfflineFallback(segment);
    }
  }

  String _getOfflineFallback(TimeSegment segment) {
    switch (segment) {
      case TimeSegment.morning:
        return "Yeni gün, kalbine huzur ve dinginlik getirsin.";
      case TimeSegment.noon:
        return "Günün ortasında kendine bir nefeslik mola ver.";
      case TimeSegment.afternoon:
        return "Zaman akıp gidiyor, ama an seninle.";
      case TimeSegment.sunset:
        return "Akşamın serinliğinde ruhunu dinlendir.";
      case TimeSegment.night:
        return "Gece, içindeki sessizliğe açılan kapıdır.";
      case TimeSegment.sahur:
        return "Seher vakti, duaların en samimi olduğu andır.";
      default:
        return "Anı yaşa, huzuru içinde bul.";
    }
  }
  
  String _getSegmentNameTr(TimeSegment s) {
     // Simple mapping for prompt context
     return s.toString().split('.').last;
  }
}
