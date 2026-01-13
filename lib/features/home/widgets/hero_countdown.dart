import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_controller.dart';

class HeroCountdown extends StatelessWidget {
  final HeroViewModel viewModel;
  final String? theme;
  final bool isRamadan;
  final String? contextSentence;

  const HeroCountdown({
    super.key,
    required this.viewModel,
    this.theme,
    this.isRamadan = false,
    this.contextSentence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme Chip (Prominent)
        if (theme != null) ...[
          _buildThemeChip(),
          const SizedBox(height: 20),
        ],
        
        // Countdown (Large, Bold)
        Text(
          viewModel.timeString,
          style: GoogleFonts.outfit(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            height: 1.0,
            letterSpacing: -2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        
        // Event Label
        Text(
          viewModel.nextEventLabel,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.95),
            letterSpacing: 1.0,
          ),
        ),
        
        // Context Sentence
        if (contextSentence != null) ...[
          const SizedBox(height: 16),
          Text(
            contextSentence!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(0.65),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThemeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 16,
            color: Colors.amber.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Text(
            "Günün Teması",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            theme ?? "",
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
