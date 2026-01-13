import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static const String _boxName = 'ufuk_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Future<void> cacheMonth(String key, Map<String, dynamic> json) async {
    final box = Hive.box(_boxName);
    await box.put(key, {
      'fetchedAt': DateTime.now().toIso8601String(),
      'data': json,
    });
  }

  Map<String, dynamic>? getMonth(String key) {
    if (!Hive.isBoxOpen(_boxName)) return null;
    
    final box = Hive.box(_boxName);
    final dynamic entry = box.get(key);
    
    if (entry != null && entry is Map) {
      // Cast explicitly to be safe
      return Map<String, dynamic>.from(entry['data'] as Map);
      
      // Note: We could check 'fetchedAt' here for 30-day expiry
      // but for MVP robustness we trust the cache if it exists for the specific month requested.
    }
    return null;
  }

  // Generic key-value methods for preferences
  Future<String?> read(String key) async {
    if (!Hive.isBoxOpen(_boxName)) return null;
    final box = Hive.box(_boxName);
    return box.get(key) as String?;
  }

  Future<void> write(String key, String value) async {
    final box = Hive.box(_boxName);
    await box.put(key, value);
  }
}
