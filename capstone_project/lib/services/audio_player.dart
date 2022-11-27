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
    if (player.state != PlayerState.PLAYING) {
      int result = await player.playBytes(audiobytes);
      if (result == 1) {
        //play success
        print("audio is playing.");
      } else {
        print("Error while playing audio.");
      }
    }
    await player.resume();
  }

  // static void close() {
  //   print('關閉 player');
  //   player.dispose();
  // }
}
