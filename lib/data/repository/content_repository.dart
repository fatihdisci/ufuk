import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class DailyContent {
  final String text;
  final String source;

  DailyContent({required this.text, required this.source});
}

class ContentRepository {

  Future<Map<String, DailyContent>> getDailyContent(DateTime date, {String? theme}) async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/content_v2.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<dynamic> allAyets = data['ayet'] ?? [];
      final List<dynamic> allHadiths = data['hadith'] ?? [];

      if (allAyets.isEmpty || allHadiths.isEmpty) {
        return _fallback();
      }
      
      // Filter by Theme if provided
      List<dynamic> ayets = allAyets;
      List<dynamic> hadiths = allHadiths;
      
      if (theme != null) {
         final themeLower = theme.toLowerCase();
         
         final filteredAyets = allAyets.where((item) {
             final tags = (item['tags'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
             return tags.contains(themeLower);
         }).toList();
         
         final filteredHadiths = allHadiths.where((item) {
             final tags = (item['tags'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
             return tags.contains(themeLower);
         }).toList();
         
         // FALLBACK RULE: Only use filtered if NOT empty
         if (filteredAyets.isNotEmpty) ayets = filteredAyets;
         if (filteredHadiths.isNotEmpty) hadiths = filteredHadiths;
      }

      // Deterministic Seed: YYYYMMDD
      final seed = date.year * 10000 + date.month * 100 + date.day;
      final random = Random(seed);
      
      final ayetIndex = random.nextInt(ayets.length);
      final hadithIndex = random.nextInt(hadiths.length);

      return {
        'ayet': DailyContent(
          text: ayets[ayetIndex]['text'],
          source: ayets[ayetIndex]['source'],
        ),
        'hadith': DailyContent(
          text: hadiths[hadithIndex]['text'],
          source: hadiths[hadithIndex]['source'],
        ),
      };
    } catch (e) {
      print('Content Repo Error: $e');
      return _fallback();
    }
  }

  Map<String, DailyContent> _fallback() {
    return {
      'ayet': DailyContent(text: "Yükleniyor...", source: ""),
      'hadith': DailyContent(text: "...", source: ""),
    };
  }
}
