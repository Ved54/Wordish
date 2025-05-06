import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  Future<void> playSound(String sound) async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/$sound.mp3'));
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  bool get isMuted => _isMuted;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
