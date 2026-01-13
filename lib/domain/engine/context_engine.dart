import 'dart:math';

class ContextEngine {
  static const List<String> _themes = [
    'Sabır',
    'Şükür',
    'Dua',
    'Tevekkül',
    'Merhamet',
    'İhlas',
    'Tevbe',
    'Adalet',
    'Tefekkür',
    'Ümit',
  ];

  /// Checks if it is currently Ramadan based on Hijri month (9).
  static bool checkRamadan(Map<String, dynamic> todayData) {
    try {
      final hijriMonth = todayData['date']['hijri']['month']['number'];
      // hijriMonth can be int or string depending on API version, safe parse
      final monthInt = int.tryParse(hijriMonth.toString()) ?? 0;
      return monthInt == 9;
    } catch (e) {
      return false; // Fail safe
    }
  }

  /// Returns a deterministic theme based on the date seed.
  static String getDailyTheme(DateTime date) {
    // Seed = YYYYMMDD
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return _themes[random.nextInt(_themes.length)];
  }

  /// Returns a label override if Ramadan conditions are met.
  static String? getRamadanLabel(bool isRamadan, DateTime now, Map<String, dynamic> todayData) {
    if (!isRamadan) return null;

    try {
      final timings = todayData['timings'];
      final imsakStr = timings['Imsak'].toString().split(' ')[0];
      final maghribStr = timings['Maghrib'].toString().split(' ')[0];

      final imsakTime = _parseTime(now, imsakStr);
      final maghribTime = _parseTime(now, maghribStr);

      if (now.isBefore(imsakTime)) {
        return "Sahura Kalan";
      } else if (now.isBefore(maghribTime)) {
        return "İftara Kalan";
      }
      
      return null; // Normal behavior after Maghrib
    } catch (e) {
      return null;
    }
  }

  static DateTime _parseTime(DateTime now, String timeStr) {
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
