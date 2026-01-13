import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/data/services/location_preferences.dart';

class LocationPickerSheet extends StatefulWidget {
  final LocationPreferences preferences;
  final SelectedLocation currentLocation;
  final Function(SelectedLocation) onLocationSelected;

  const LocationPickerSheet({
    super.key,
    required this.preferences,
    required this.currentLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  Province? _selectedProvince;
  String? _searchQuery;
  
  @override
  void initState() {
    super.initState();
    _selectedProvince = widget.preferences.getProvinceByName(widget.currentLocation.provinceName);
  }

  List<Province> get _filteredProvinces {
    final provinces = widget.preferences.getProvinces();
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return provinces;
    }
    final query = _searchQuery!.toLowerCase();
    return provinces.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (_selectedProvince != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => setState(() => _selectedProvince = null),
                  ),
                Expanded(
                  child: Text(
                    _selectedProvince?.name ?? 'İl Seçin',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search (only for provinces)
          if (_selectedProvince == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'İl ara...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          // List
          Expanded(
            child: _selectedProvince == null
                ? _buildProvinceList()
                : _buildDistrictList(_selectedProvince!),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceList() {
    final provinces = _filteredProvinces;
    return ListView.builder(
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        final province = provinces[index];
        return ListTile(
          title: Text(
            province.name,
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          onTap: () {
            if (province.districts.isEmpty) {
              // No districts, select province directly
              _selectLocation(province, null);
            } else {
              setState(() => _selectedProvince = province);
            }
          },
        );
      },
    );
  }

  Widget _buildDistrictList(Province province) {
    return ListView.builder(
      itemCount: province.districts.length + 1, // +1 for "Merkez" option
      itemBuilder: (context, index) {
        if (index == 0) {
          // Province center
          return ListTile(
            title: Text(
              '${province.name} (Merkez)',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            leading: const Icon(Icons.location_city, color: Colors.amber),
            onTap: () => _selectLocation(province, null),
          );
        }
        
        final district = province.districts[index - 1];
        return ListTile(
          title: Text(
            district,
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          onTap: () => _selectLocation(province, district),
        );
      },
    );
  }

  void _selectLocation(Province province, String? district) {
    final location = SelectedLocation(
      provinceName: province.name,
      districtName: district,
      lat: province.lat,
      lng: province.lng,
    );
    
    widget.onLocationSelected(location);
    Navigator.pop(context);
  }
}
