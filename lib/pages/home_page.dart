import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
     throw 'Microphone permission not granted.';
    }

    await recorder.openRecorder();
  }

  Future record() async {
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    await recorder.stopRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();

    super.dispose();
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
                    colors: const [
                      Color(0xffef0940),
                      Color(0xFF8F19EF),
                      // Color(0xFF0827E8)
                    ],
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

                    child: Icon(
                      recorder.isRecording ? Icons.stop : Icons.mic,
                      size: 80,
                      color: Colors.red
                    ),
                  )
                  //RawMaterialButton(
                  //  onPressed: () {},
                  //  elevation: 2.0,
                  //  fillColor: Colors.red,
                  //  child: Icon(
                  //    Icons.mic,
                  //    size: 80.0,
                  //  ),
                  //  padding: EdgeInsets.all(15.0),
                  //  shape: CircleBorder(),
                  //)

    ])));
  }
}
