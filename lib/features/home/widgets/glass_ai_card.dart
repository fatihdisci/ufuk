import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ufuk/app/theme/glass_tokens.dart';

class GlassAiCard extends StatelessWidget {
  final String text;
  final VoidCallback onShare;

  const GlassAiCard({super.key, required this.text, required this.onShare});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: 280, // Same width as other cards for consistency, or slightly different?
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GlassTokens.borderRadius),
        color: GlassTokens.cardColor.withOpacity(0.08), // Slightly different tint for "Special" feel
        border: Border.all(
          color: Colors.amber.withOpacity(0.3), // Goldish tint for "Wisdom"
          width: 0.5,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber.withOpacity(0.6), size: 16),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay( // Serif for Wisdom
                fontSize: 16,
                height: 1.4,
                color: Colors.white.withOpacity(0.95),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Share Button
            GestureDetector(
              onTap: onShare,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ios_share, size: 14, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 6),
                    Text(
                      "Paylaş",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
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
