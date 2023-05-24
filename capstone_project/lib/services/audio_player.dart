import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  static AudioPlayer player = AudioPlayer();
  static String alarmAudioPath = "assets/audio/warning_tone.mp3";

  static void playAudio() async {
    ByteData bytes =
        await rootBundle.load(alarmAudioPath); //load audio from assets
    Uint8List audiobytes =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    if (player.state == PlayerState.completed) {
      await player.play(AssetSource(alarmAudioPath));
    }
    await player.resume();
  }
}
