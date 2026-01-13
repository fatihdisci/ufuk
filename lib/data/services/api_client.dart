import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'User-Agent': 'UFUK-App/1.0',
    },
  ));

  Future<Map<String, dynamic>> getCalendar(double lat, double lng, int month, int year) async {
    try {
      final response = await _dio.get(
        '/calendar',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'method': 13, // Diyanet
          'month': month,
          'year': year,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Invalid response: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
