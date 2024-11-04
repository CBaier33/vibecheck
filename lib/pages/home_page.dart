import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import "package:http/http.dart" as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  // Gradient Colors
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;


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
    // Add more mappings if needed
  };

  // Adjust color intensity based on the score
  Color _adjustColorIntensity(Color color, double score) {
    final hsvColor = HSVColor.fromColor(color);
    final intensity = (0.5 + score * 0.5).clamp(0.5, 1.0); // Scale score to [0.5, 1.0]
    return hsvColor.withValue(intensity).toColor(); // Adjust brightness based on score
  }

  // Microphone functions & permissions
  final recorder = FlutterSoundRecorder();

  String vibeFile = '';

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted.';
    }

    await recorder.openRecorder();
  }

  Future<String?> record() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath =
        '${tempDir.path}/vibecheck.wav'; // Adjust the file extension if necessary

    await recorder.startRecorder(toFile: filePath);
    print("Recording started, saving to $filePath");

    vibeFile = filePath;

    return filePath; // Return the path for later use
  }

  Future stop() async {
    await recorder.stopRecorder();
    sendToModel(vibeFile);
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
  }

  // API Call
  Future<void> sendToModel(String filePath) async {

    final url = Uri.parse('https://api-inference.huggingface.co/models/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition/');

    // Read the file as bytes
    File audioFile = File(filePath);
    List<int> fileBytes = await audioFile.readAsBytes();

    // Create the request
    var request = http.Request('POST', url)
      ..headers['Authorization'] = 'Bearer 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'  // Replace with your API key
      ..bodyBytes = fileBytes;  // Directly set the body as bytes

    // Send the request
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        List<dynamic> resultList = jsonDecode(responseBody);

        // Sort the list by score in descending order
        resultList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

        // Take the top two results
        final topResults = resultList.take(2).toList();

        // Map labels to colors
        List<Color> newColors = topResults
            .map((result) {
          Color baseColor = emotionBaseColors[result['label']] ?? Colors.grey;
          return _adjustColorIntensity(baseColor, result['score']);
        })
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

    initRecorder();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));

    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext, context) {
            return Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
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
          if (recorder.isRecording) {
            await stop();
          } else {
            await record();
          }

          setState(() {});
        },
        child: Icon(recorder.isRecording ? Icons.stop : Icons.mic,
            size: 80, color: Colors.red),
      )
    ])));
  }
}
