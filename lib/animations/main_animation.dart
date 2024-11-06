import 'package:flutter/material.dart';

class GradientAnimationController {
  final AnimationController controller;
  final Animation<Alignment> topAlignment;
  final Animation<Alignment> bottomAlignment;

  GradientAnimationController({required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync, duration: const Duration(seconds: 9)),
        topAlignment = TweenSequence<Alignment>([
          TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
        ]).animate(vsync as AnimationController),
        bottomAlignment = TweenSequence<Alignment>([
          TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
        ]).animate(vsync as AnimationController);

  void start() {
    controller.repeat();
  }

  void dispose() {
    controller.dispose();
  }
}
