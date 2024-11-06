import 'package:flutter/material.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'dart:async';
import '../services/audio_recorder.dart';
import '../animations/main_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  //// Animation Controllers
  //late AnimationController _controller;
  //late Animation<Alignment> _topAlignmentAnimation;
  //late Animation<Alignment> _bottomAlignmentAnimation;

  late GradientAnimationController gradientController;

  // Gradient Colors
  List<Color> _gradientColors = [Colors.red, Colors.purple];

  // Rainbow colors mapped to emotion labels
  final Map<String, Color> emotionBaseColors = {
    'angry': Colors.red,
    'calm': Colors.green,
    'disgust': Colors.green.shade700,
    'fearful': Colors.deepPurple,
    'happy': Colors.yellow,
    'neutral': Color(0xFFD2B48C),
    'sad': Colors.blue,
    'surprised': Colors.orange,
  };

  // Microphone functions & permissions
  final AudioRecorder recorder = AudioRecorder();

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
      sendToAudioModel(recorder.vibeFile);
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

  // API Call
  Future<void> sendToAudioModel(String filePath) async {
    final url = Uri.parse(
        'https://api-inference.huggingface.co/models/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition/');

    // Read the file as bytes
    File audioFile = File(filePath);
    List<int> fileBytes = await audioFile.readAsBytes();

    // Create the request
    var request = http.Request('POST', url)
      ..headers['Authorization'] =
          'Bearer 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' // Replace with your API key
      ..bodyBytes = fileBytes; // Directly set the body as bytes

    // Send the request
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        List<dynamic> resultList = jsonDecode(responseBody);

        // Sort the list by score in descending order
        resultList.sort(
            (a, b) => (b['score'] as double).compareTo(a['score'] as double));

        // Take the top two results
        final topResults = resultList.take(2).toList();

        // Get top two results and map them to colors
        List<Color> newColors = topResults
            .map((result) => emotionBaseColors[result['label']] ?? Colors.grey)
            .toList();

        // Update state with new gradient colors
        setState(() {
          _gradientColors = newColors;
        });

        // Display the results
        for (var result in topResults) {
          print('Label: ${result['label']}, Score: ${result['score']}');
        }
      } else {
        print("Failed to send file: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    recorder.initRecorder();

    gradientController = GradientAnimationController(vsync: this);
    gradientController.start();

    //_controller =
    //    AnimationController(vsync: this, duration: const Duration(seconds: 9));

    //_topAlignmentAnimation = TweenSequence<Alignment>(
    //  [
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.topLeft, end: Alignment.topRight),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.topRight, end: Alignment.bottomRight),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //      weight: 1,
    //    ),
    //  ],
    //).animate(_controller);

    //_bottomAlignmentAnimation = TweenSequence<Alignment>(
    //  [
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.topLeft, end: Alignment.topRight),
    //      weight: 1,
    //    ),
    //    TweenSequenceItem<Alignment>(
    //      tween: Tween<Alignment>(
    //          begin: Alignment.topRight, end: Alignment.bottomRight),
    //      weight: 1,
    //    ),
    //  ],
    //).animate(_controller);

    //_controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
          animation: gradientController.controller,
          builder: (BuildContext, context) {
            return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: gradientController.topAlignment.value,
                    end: gradientController.bottomAlignment.value,
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
