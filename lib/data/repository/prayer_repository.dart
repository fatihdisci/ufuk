import 'package:ufuk/data/services/api_client.dart';
import 'package:ufuk/data/local/hive_storage.dart';

class PrayerRepository {
  final ApiClient _apiClient = ApiClient();
  final HiveStorage _hiveStorage = HiveStorage();

  // Initialize storage once
  Future<void> init() => _hiveStorage.init();

  // Returns Raw Data list for the requested month using provided coordinates
  Future<List<dynamic>> getPrayerTimesForMonth(int year, int month, {required double lat, required double lng}) async {
    // 1. Generate Cache Key
    final latStr = lat.toStringAsFixed(2);
    final lngStr = lng.toStringAsFixed(2);
    final key = 'prayers_v1_${latStr}_${lngStr}_${year}_$month';

    // 2. Try Cache
    final cached = _hiveStorage.getMonth(key);
    if (cached != null && cached['data'] is List) {
      print('CACHE HIT for $key');
      return cached['data'];
    }

    // 3. Try Network
    try {
      print('API FETCH for $key');
      final result = await _apiClient.getCalendar(lat, lng, month, year);

      final dataList = result['data'];
      if (dataList is List) {
        // 4. Save to Cache
        await _hiveStorage.cacheMonth(key, result);
        return dataList;
      }
      return [];
    } catch (e) {
      if (cached != null) {
        return cached['data'];
      }
      rethrow;
    }
  }
}
