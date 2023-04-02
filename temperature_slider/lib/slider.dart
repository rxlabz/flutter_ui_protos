import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'constants.dart';

class ThermoSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onValueChanged;

  const ThermoSlider({
    required this.value,
    required this.onValueChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final refHeight = constraints.maxHeight - thumbSize * 1.8;
        var ratio = 1 - value / maxTemperature;

        final trackTop = refHeight * ratio;

        final color = colorTween.transform(ratio)!;

        return Stack(
          children: [
            Positioned.fill(
              top: 25,
              child: CustomPaint(
                painter: CustomSliderTrackShapePainter(
                  value: ratio,
                  color: color,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: ui.clampDouble(trackTop, 30, refHeight /*- thumbSize*/),
              child: CustomSliderThumb(
                refHeight: refHeight,
                trackTop: trackTop,
                onValueChanged: onValueChanged,
                color: color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomSliderThumb extends StatefulWidget {
  const CustomSliderThumb({
    super.key,
    required this.refHeight,
    required this.trackTop,
    required this.onValueChanged,
    required this.color,
  });

  final double refHeight;
  final double trackTop;
  final ValueChanged<double> onValueChanged;
  final ui.Color color;

  @override
  State<CustomSliderThumb> createState() => _CustomSliderThumbState();
}

class _CustomSliderThumbState extends State<CustomSliderThumb> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (d) => setState(() => active = true),
      onVerticalDragEnd: (d) => setState(() => active = false),
      onVerticalDragUpdate: (d) {
        final newValue = (widget.refHeight - widget.trackTop - d.delta.dy) /
            widget.refHeight *
            maxTemperature;
        widget.onValueChanged(ui.clampDouble(newValue, 0, 50));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: thumbSize,
        height: thumbSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white70,
              active ? widget.color : Colors.grey.shade300,
            ],
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(3, 0),
              blurRadius: 2,
              spreadRadius: 1,
              color: Colors.grey.shade400,
              blurStyle: BlurStyle.inner,
            ),
          ],
        ),
      ),
    );
  }
}

final colorTween = TweenSequence<Color?>(
  [
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.red, end: Colors.orange).chain(
          CurveTween(curve: const Interval(0.0, 0.15, curve: Curves.linear))),
      weight: 0.25,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.orange, end: Colors.amber).chain(
          CurveTween(curve: const Interval(0.15, 0.3, curve: Curves.linear))),
      weight: 0.25,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.amber, end: Colors.lightGreen).chain(
          CurveTween(curve: const Interval(0.3, 0.5, curve: Curves.linear))),
      weight: 0.25,
    ),
    TweenSequenceItem(
      tween: ColorTween(begin: Colors.lightGreen, end: Colors.cyan).chain(
          CurveTween(curve: const Interval(0.5, .7, curve: Curves.linear))),
      weight: 0.25,
    ),
  ],
);

class CustomSliderTrackShapePainter extends CustomPainter {
  final double value;

  final Color color;

  CustomSliderTrackShapePainter({required this.value, required this.color});

  final thickness = 4.0;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    const marginRight = 24.0;

    var refHeight =
    (size.height - thumbSize + ((value - .35) * 14) - (value + .1) * 30);

    final path = Path()
      ..moveTo(marginRight, 0)
      ..lineTo(marginRight, refHeight * (value) - 60)
      ..cubicTo(
        marginRight,
        refHeight * (value) - 20,
        marginRight / 3,
        refHeight * (value) - 40,
        0,
        max(
          thumbSize / 2 + 10,
          refHeight * (value),
        ),
      )
      ..cubicTo(
        0,
        max(80, refHeight * (value) + 40),
        marginRight,
        max(60, refHeight * (value) + 30),
        marginRight,
        max(100, refHeight * (value) + 60),
      )
      ..lineTo(marginRight, size.height) /*..lineTo(marginRight, 0)*/;

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, size.height),
          [Colors.grey.shade300.withOpacity(0), color, color.withOpacity(0)],
          [0, ui.clampDouble(value, .1, .9), 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomSliderTrackShapePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
