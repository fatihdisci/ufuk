import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/common/widgets/glass_card.dart';

class GlassNativeAd extends StatelessWidget {
  final NativeAd nativeAd;

  const GlassNativeAd({super.key, required this.nativeAd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GlassCard(
        child: Stack(
          children: [
            // Ad Content
            AdWidget(ad: nativeAd),
            
            // "Sponsored" Label (Overlay to ensure visibility/compliance if needed, 
            // though NativeTemplate has its own label usually. We'll add a subtle header if template doesn't cover it enough,
            // or rely on the template. Let's rely on template for now but ensure container is sized.)
             Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "SPONSORED",
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.white38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
