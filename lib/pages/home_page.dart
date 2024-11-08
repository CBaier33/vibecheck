import 'package:flutter/material.dart';
import 'dart:async';
import '../services/audio_recorder.dart';
import '../services/api_service.dart';
import '../animations/main_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  late GradientAnimationController gradientController; // Animation Controllers
  final ApiService apiService = ApiService(); // API Service
  final AudioRecorder recorder = AudioRecorder(); // Microphone functions & permissions

  List<Color> _gradientColors = [Colors.teal, Colors.black]; // Gradient Colors
  String _emotionLabel = '';

  // Recording style -> audio or text
  String recordingStyle = 'audio';

  Future record() async {
    if (recordingStyle == 'audio') {
      await recorder.record();
    }
  }

  Future stop() async {
    if (recordingStyle == 'audio') {
      await recorder.stop();
      List<dynamic>? results = await apiService.sendToAudioModel(recorder.vibeFile);

      print(results);

      if (results != null) {
        List<Color>? newColors = results[0];
        List<String>? emotions = results[1];

        if (newColors != null) {
          setState(() {
            _gradientColors = newColors;
          });

          if (emotions != null) {

            String emotion = emotions.join('_');
            String? emotionMatch = apiService.getAudioEmotionPairName(emotion);

            if (emotionMatch != null) {
              String emotionLabel = '$emotionMatch (${emotions.join(', ')})';

              setState(() {
                _emotionLabel = emotionLabel;
              });
           }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    if (recordingStyle == 'audio') {
      recorder.dispose();
    }
    super.dispose();
  }

  bool isRecording() {
    if (recordingStyle == 'audio') {
      return recorder.recorder.isRecording;
    } else {
     // handle text recording
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    recorder.initRecorder();
    gradientController = GradientAnimationController(this);
    //apiService.initializeAudioEmotionPairNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_emotionLabel),
      AnimatedBuilder(
          animation: gradientController.controller,
          builder: (BuildContext, context) {
            return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: gradientController.topAlignmentAnimation.value,
                    end: gradientController.bottomAlignmentAnimation.value,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ));
          }),
      const Text('vibecheck',
          style: TextStyle(
            fontSize: 40,
            height: 2,
            fontFamily: 'Georgia',
          )),
      const SizedBox(width: 10, height: 10),
      RawMaterialButton(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(15.0),
        onPressed: () async {
          if (isRecording()) {
            await stop();
          } else {
            await record();
          }
          setState(() {});
        },
        child: Icon(isRecording() ? Icons.stop : Icons.mic,
            size: 80, color: Colors.red),
      )
    ])));
  }
}
