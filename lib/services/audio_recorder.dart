import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecorder {
  final recorder = FlutterSoundRecorder();

  String vibeFile = '';

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted.';
    }
    await recorder.openRecorder();
  }

  Future record() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/vibecheck.wav';

    await recorder.startRecorder(toFile: filePath);

    vibeFile = filePath;
  }

  Future stop() async {
    await recorder.stopRecorder();
  }

  void dispose() {
    recorder.closeRecorder();
  }
}
