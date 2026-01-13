import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_controller.dart';

class PrayerTimelineCard extends StatelessWidget {
  final List<PrayerTimeDisplay> times;
  final String? currentPrayerName;

  const PrayerTimelineCard({
    super.key,
    required this.times,
    this.currentPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    if (times.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                "Vakit Çizelgesi",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Timeline Grid (2 columns)
          Row(
            children: [
              Expanded(child: _buildColumn(times.take(3).toList())),
              const SizedBox(width: 16),
              Expanded(child: _buildColumn(times.skip(3).toList())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(List<PrayerTimeDisplay> columnTimes) {
    return Column(
      children: columnTimes.map((t) => _buildTimeRow(t)).toList(),
    );
  }

  Widget _buildTimeRow(PrayerTimeDisplay time) {
    final bool isCurrent = time.name == currentPrayerName;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? Colors.amber : Colors.white38,
              boxShadow: isCurrent
                  ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          
          // Name
          Expanded(
            child: Text(
              time.name,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? Colors.white : Colors.white70,
              ),
            ),
          ),
          
          // Time
          Text(
            time.time,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: isCurrent ? Colors.amber : Colors.white60,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
