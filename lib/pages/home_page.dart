import 'package:flutter/material.dart';
import 'dart:async';
import '../services/audio_recorder.dart';
import '../services/api_service.dart';
import '../animations/main_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  //// Animation Controllers
  late GradientAnimationController gradientController;

  final List<Color> _defaultGradient = [Colors.purpleAccent, Colors.tealAccent]; // Gradient Colors
  List<Color> _gradientColors = [Colors.purpleAccent, Colors.tealAccent]; // Gradient Colors

  //// API Service
  final ApiService apiService = ApiService();

  String _emotionLabel = '';

  bool isLoading = false;

  void _updateLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  //// Microphone functions & permissions
  final AudioRecorder recorder = AudioRecorder();

  // Recording style -> audio or text
  String recordingStyle = 'audio';

  Future record() async {
    if (recordingStyle == 'audio') {
      setState(() {
        _emotionLabel = '';
        _gradientColors = [Colors.white, Colors.white];
        _gradientColors = _defaultGradient;
      });
      await recorder.record();
    }
  }

  Future stop() async {
    if (recordingStyle == 'audio') {
      await recorder.stop();

      _updateLoading(true);
      List<dynamic>? results =
          await apiService.sendToAudioModel(recorder.vibeFile);
      _updateLoading(false);

      if (results != null) {
        List<Color>? newColors = results[0];
        List<String>? emotions = results[1];

        if (newColors != null) {
          setState(() {
            _gradientColors = [Colors.white, Colors.white];
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
      } else {
        setState(() {
          _emotionLabel = "Please try again.";
        });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(_emotionLabel,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontStyle: FontStyle.italic,
            fontSize: 15,
          )),
      AnimatedBuilder(
        animation: gradientController.controller,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Use AnimatedContainer to smoothly transition gradient colors
              AnimatedContainer(
                duration: Duration(milliseconds: 500), // Duration of the fade effect
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: gradientController.topAlignmentAnimation.value,
                    end: gradientController.bottomAlignmentAnimation.value,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // Show a centered loading spinner if isLoading is true
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
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
      ),
    ])));
  }
}
