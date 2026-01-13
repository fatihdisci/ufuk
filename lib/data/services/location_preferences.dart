import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ufuk/data/local/hive_storage.dart';

class LocationPreferences {
  static const String _selectedLocationKey = 'selected_location';
  
  final HiveStorage _storage = HiveStorage();
  List<Province>? _provinces;
  
  // Default: İstanbul
  static const String defaultProvinceName = 'İstanbul';
  static const double defaultLat = 41.01;
  static const double defaultLng = 28.98;

  Future<void> init() async {
    await _storage.init();
    await _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/turkey_locations.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> provinceList = data['provinces'] ?? [];
      
      _provinces = provinceList.map((p) => Province.fromJson(p)).toList();
    } catch (e) {
      print('LocationPreferences: Error loading provinces: $e');
      _provinces = [];
    }
  }

  List<Province> getProvinces() => _provinces ?? [];

  Province? getProvinceByName(String name) {
    return _provinces?.firstWhere(
      (p) => p.name == name,
      orElse: () => _provinces!.firstWhere((p) => p.name == defaultProvinceName),
    );
  }

  Future<SelectedLocation> getSelectedLocation() async {
    final cached = await _storage.read(_selectedLocationKey);
    if (cached != null) {
      try {
        return SelectedLocation.fromJson(json.decode(cached));
      } catch (e) {
        // Corrupted cache, return default
      }
    }
    
    // Default: İstanbul
    return SelectedLocation(
      provinceName: defaultProvinceName,
      districtName: null,
      lat: defaultLat,
      lng: defaultLng,
    );
  }

  Future<void> saveSelectedLocation(SelectedLocation location) async {
    await _storage.write(_selectedLocationKey, json.encode(location.toJson()));
  }
}

class Province {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final List<String> districts;

  Province({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.districts,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      districts: List<String>.from(json['districts'] ?? []),
    );
  }
}

class SelectedLocation {
  final String provinceName;
  final String? districtName;
  final double lat;
  final double lng;

  SelectedLocation({
    required this.provinceName,
    this.districtName,
    required this.lat,
    required this.lng,
  });

  String get displayName => districtName != null 
      ? '$districtName, $provinceName' 
      : provinceName;

  factory SelectedLocation.fromJson(Map<String, dynamic> json) {
    return SelectedLocation(
      provinceName: json['provinceName'],
      districtName: json['districtName'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'provinceName': provinceName,
    'districtName': districtName,
    'lat': lat,
    'lng': lng,
  };
}
