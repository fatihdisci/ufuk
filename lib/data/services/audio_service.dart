import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  
  // Expose player state if needed, but keeping it simple for now
  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    // Set global context to avoid ducking if other apps play music? 
    // For now, default behavior is fine.
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playAmbient(String assetPath) async {
    try {
      if (_isPlaying) {
        // If already playing, maybe crossfade? For MVP, just switch.
        await _player.stop();
      }
      
      // Ensure loop mode is set
      await _player.setReleaseMode(ReleaseMode.loop);
      
      // Source
      await _player.setSource(AssetSource(assetPath.replaceFirst('assets/', '')));
      
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      // Fail silently or log
      print('AudioService Error: $e');
    }
  }

  Future<void> togglePlayPause(String defaultAsset) async {
    if (_isPlaying) {
      await pause();
    } else {
      // If we have a source set, resume. If not, play default.
      // Since AudioPlayer state is complex, for MVP simple toggle:
      if (_player.source != null) {
        await resume();
      } else {
         await playAmbient(defaultAsset);
      }
    }
  }
  
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }
  
  void dispose() {
    _player.dispose();
  }
}
