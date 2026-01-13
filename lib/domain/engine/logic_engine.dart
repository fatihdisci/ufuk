import 'package:ufuk/app/atmosphere/segment.dart'; // Reuse the enum

class AtmosphereEngine {
  static TimeSegment resolveSegment(DateTime now, Map<String, dynamic> todayTimes) {
    // Parse times "HH:mm" -> DateTime for today
    // This is a simplified engine for MVP phase logic verification
    
    // We assume todayTimes comes from Aladhan "timings" map
    // { "Fajr": "05:00", "Sunrise": "06:30", "Dhuhr": "13:00", ... }
    
    final timings = todayTimes['timings'];
    if (timings == null) return TimeSegment.morning; // Default

    final DateTime imsak = _parseTime(now, timings['Imsak']);
    final DateTime sunrise = _parseTime(now, timings['Sunrise']);
    final DateTime dhuhr = _parseTime(now, timings['Dhuhr']);
    final DateTime asr = _parseTime(now, timings['Asr']);
    final DateTime maghrib = _parseTime(now, timings['Maghrib']);
    final DateTime isha = _parseTime(now, timings['Isha']);

    if (now.isBefore(imsak)) return TimeSegment.night; // Or sahur if close
    if (now.isBefore(sunrise)) return TimeSegment.sahur;
    if (now.isBefore(dhuhr)) return TimeSegment.morning;
    if (now.isBefore(asr)) return TimeSegment.noon;
    if (now.isBefore(maghrib)) return TimeSegment.afternoon;
    if (now.isBefore(isha)) return TimeSegment.sunset;
    
    return TimeSegment.night;
  }

  static DateTime _parseTime(DateTime now, String hhmm) {
    // Remove (EET) suffix if present
    final clean = hhmm.split(' ')[0];
    final parts = clean.split(':');
    return DateTime(
      now.year, now.month, now.day, 
      int.parse(parts[0]), int.parse(parts[1])
    );
  }
}

enum EventType {
  prayer,
  iftar,
  sahur,
}

class NextEvent {
  final EventType type;
  final Duration remaining;
  final String label;

  NextEvent(this.type, this.remaining, this.label);
}

class CountdownEngine {
  static NextEvent resolveNextEvent(DateTime now, Map<String, dynamic> todayData) {
    final timings = todayData['timings'];
    final hijriMonth = todayData['date']['hijri']['month']['number'];
    final bool isRamadan = (hijriMonth == 9);

    if (timings == null) return NextEvent(EventType.prayer, Duration.zero, 'Loading');

    // Parse all critical times
    final DateTime imsak = AtmosphereEngine._parseTime(now, timings['Imsak']);
    final DateTime sunrise = AtmosphereEngine._parseTime(now, timings['Sunrise']);
    final DateTime dhuhr = AtmosphereEngine._parseTime(now, timings['Dhuhr']);
    final DateTime asr = AtmosphereEngine._parseTime(now, timings['Asr']);
    final DateTime maghrib = AtmosphereEngine._parseTime(now, timings['Maghrib']);
    final DateTime isha = AtmosphereEngine._parseTime(now, timings['Isha']);

    // LOGIC
    // 1. Ramadan overrides
    if (isRamadan) {
      // Pre-Iftar (After Asr, or generally while fasting)
      if (now.isAfter(imsak) && now.isBefore(maghrib)) {
         return NextEvent(EventType.iftar, maghrib.difference(now), 'İftara Kalan');
      }
      // Pre-Sahur (Night)
      if (now.isAfter(isha) || now.isBefore(imsak)) {
        // Handle overflow (imsak is tomorrow?) - kept simple for MVP logic verification
        final target = now.isBefore(imsak) ? imsak : imsak.add(const Duration(days: 1)); // buggy simplistic logic fix later
        // actually if now > isha, target is tomorrow's imsak. 
        // For MVP verification, let's just assume same day checks for now or fix this logic in Phase 3
        
        return NextEvent(EventType.sahur, target.difference(now), 'Sahura Kalan');
      }
    }

    // 2. Normal Prayer Sequence
    if (now.isBefore(imsak)) return NextEvent(EventType.prayer, imsak.difference(now), 'İmsak Vakti');
    if (now.isBefore(sunrise)) return NextEvent(EventType.prayer, sunrise.difference(now), 'Güneş');
    if (now.isBefore(dhuhr)) return NextEvent(EventType.prayer, dhuhr.difference(now), 'Öğle Vakti');
    if (now.isBefore(asr)) return NextEvent(EventType.prayer, asr.difference(now), 'İkindi Vakti');
    if (now.isBefore(maghrib)) return NextEvent(EventType.prayer, maghrib.difference(now), 'Akşam Vakti');
    if (now.isBefore(isha)) return NextEvent(EventType.prayer, isha.difference(now), 'Yatsı Vakti');

    // If after Isha, next is Imsak (Tomorrow)
    return NextEvent(EventType.prayer, imsak.add(const Duration(days: 1)).difference(now), 'İmsak Vakti');
  }
}
