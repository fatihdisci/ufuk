import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ufuk/app/theme/glass_tokens.dart';
import 'package:ufuk/data/services/audio_service.dart';

class GlassPlayer extends StatefulWidget {
  const GlassPlayer({super.key});

  @override
  State<GlassPlayer> createState() => _GlassPlayerState();
}

class _GlassPlayerState extends State<GlassPlayer> {
  // defaulting to ney for now as per PRD "Ramadan Mode" vibe
  // ideally this comes from a state manager if switching assets dynamically
  final String _currentAsset = 'assets/audio/ney.mp3'; 
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = AudioService().isPlaying;
  }

  void _toggle() async {
    await AudioService().togglePlayPause(_currentAsset);
    if (mounted) {
      setState(() {
        _isPlaying = AudioService().isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50), // Pill shape
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassTokens.blurRadius,
          sigmaY: GlassTokens.blurRadius,
        ),
        child: Container(
          height: 48,
          width: 48, // Start small (icon only) - Expand logic can be added later
          decoration: BoxDecoration(
            color: GlassTokens.cardColor.withOpacity(GlassTokens.cardOpacity),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: GlassTokens.borderColor.withOpacity(GlassTokens.borderOpacity),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(50),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.music_note_rounded,
                color: Colors.white.withOpacity(0.9), // High visibility
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
