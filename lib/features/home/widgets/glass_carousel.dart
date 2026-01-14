import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/common/widgets/glass_card.dart';
import 'package:ufuk/data/repository/content_repository.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../monetization/glass_native_ad.dart';
import '../home_controller.dart';
import 'glass_ai_card.dart';

class GlassCarousel extends StatelessWidget {
  final List<PrayerTimeDisplay> times; // Kept for compatibility, not used
  final Map<String, DailyContent> content;
  final Function(DailyContent) onShare;
  final Function(String)? onAiShare; // New callback for AI text
  final NativeAd? nativeAd;
  final String? aiSummary;

  const GlassCarousel({
    super.key, 
    required this.times, 
    required this.content,
    required this.onShare,
    this.onAiShare,
    this.nativeAd,
    this.aiSummary,
  });

  @override
  Widget build(BuildContext context) {
    // Build list of cards dynamically
    final List<Widget> cards = [];

    // AI Summary Card (Index 0)
    if (aiSummary != null && aiSummary!.isNotEmpty) {
      cards.add(GlassAiCard(
        text: aiSummary!,
        onShare: () {
          if (onAiShare != null) {
            onAiShare!(aiSummary!);
          }
        },
      ));
    }
    
    // Ayet Card
    if (content.containsKey('ayet')) {
      cards.add(_buildContentCard("Günün Ayeti", content['ayet']!, Icons.menu_book));
    }
    
    // Hadis Card
    if (content.containsKey('hadith')) {
      cards.add(_buildContentCard("Günün Hadisi", content['hadith']!, Icons.format_quote));
    }
    
    // Native Ad Card (if available)
    if (nativeAd != null) {
      cards.add(GlassNativeAd(nativeAd: nativeAd!));
    }
    
    if (cards.isEmpty) return const SizedBox.shrink();

    return PageView(
      controller: PageController(viewportFraction: 0.88),
      children: cards,
    );
  }

  Widget _buildContentCard(String title, DailyContent item, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.white54),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Share CTA
                GestureDetector(
                  onTap: () => onShare(item),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.share_outlined, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          "Paylaş",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "— ${item.source}",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
