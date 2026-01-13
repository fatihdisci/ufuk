import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/app/atmosphere/segment.dart';
import 'package:ufuk/data/repository/content_repository.dart';
import 'package:ufuk/features/home/widgets/atmosphere_bg.dart';

class ShareCard extends StatelessWidget {
  final DailyContent content;
  final TimeSegment segment;

  const ShareCard({super.key, required this.content, required this.segment});

  @override
  Widget build(BuildContext context) {
    // 9:16 Logical Design (e.g. 360x640 logical, rendered 3x pixel ratio -> 1080x1920)
    return Container(
      width: 360,
      height: 640,
      decoration: const BoxDecoration(
        color: Colors.black, // Fallback
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Reusing Atmosphere Logic
          AtmosphereBackground(segment: segment),
          
          // Content Overlay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Icon / Logo Mark
                const Icon(Icons.auto_awesome, color: Colors.white54, size: 32),
                const SizedBox(height: 32),

                // Main Text
                Text(
                  content.text,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    height: 1.6,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),

                // Source
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "- ${content.source}",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                const Spacer(),

                // Footer / Watermark
                Opacity(
                  opacity: 0.6,
                  child: Column(
                    children: [
                      Text(
                        'Via UFUK',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Huzur ve İbadet Vakti',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
