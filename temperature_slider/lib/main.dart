import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen());
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.grey.shade100,
        body: TemperatureView());
  }
}

class TemperatureView extends StatelessWidget {
  final ValueNotifier<double> temperature = ValueNotifier(20.0);

  TemperatureView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
      valueListenable: temperature,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                '${temperature.value.toInt()}°',
                style: textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Thermo(temperature: temperature),
            ),
            Slider(
              value: temperature.value,
              min: 0,
              max: 50,
              onChanged: (value) => temperature.value = value,
            ),
            const TemperatureIconBar(index: 1)
          ],
        );
      },
    );
  }
}

class Thermo extends StatefulWidget {
  const Thermo({
    super.key,
    required this.temperature,
  });

  final ValueNotifier<double> temperature;

  @override
  State<Thermo> createState() => _ThermoState();
}

class _ThermoState extends State<Thermo> with SingleTickerProviderStateMixin {
  late final AnimationController anim;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return CustomPaint(
          painter:
              ThermoPainter(widget.temperature.value, animation: anim.value),
        );
      },
    );
  }
}

class TemperatureIconBar extends StatelessWidget {
  final int index;

  const TemperatureIconBar({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 92, vertical: 64),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.severe_cold),
          const Icon(Icons.water_drop),
          const Icon(Icons.local_fire_department),
        ],
      ),
    );
  }
}

const thermoWidth = 96.0;
const vPadding = 10.0;
const thickness = 8.0;
const radius = thermoWidth / 2;

class ThermoPainter extends CustomPainter {
  /// min 0 / Max 50
  final double temperature;

  final double animation;

  ThermoPainter(this.temperature, {required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // background
    _drawBackground(canvas, size);

    //container
    final topLeft = Offset(
      (size.width - thermoWidth) / 2 + thickness,
      vPadding + thickness,
    );
    final bottomRight = Offset(
      (size.width + thermoWidth) / 2 - thickness,
      size.height - vPadding - thickness,
    );

    drawContainer(canvas, topLeft, bottomRight);

    // mask
    _drawMask(canvas, size);

    _drawLiquid(canvas, size, bottomRight, topLeft);

    // white border
    _drawContainerBorder(canvas, topLeft, bottomRight);

    // reflets
    _drawReflections(size, canvas);
  }

  void _drawContainerBorder(
      ui.Canvas canvas, ui.Offset topLeft, ui.Offset bottomRight) {
    return canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(topLeft, bottomRight),
        const Radius.circular(thermoWidth),
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  void _drawMask(ui.Canvas canvas, ui.Size size) {
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(
              (size.width - thermoWidth) / 2 + thickness, vPadding + thickness),
          Offset((size.width + thermoWidth) / 2 - thickness,
              size.height - vPadding - thickness),
        ),
        const Radius.circular(48),
      ),
    );
  }

  void _drawReflections(ui.Size size, ui.Canvas canvas) {
    var refletTopLeft1 = Offset(
      size.width / 2,
      vPadding + thickness + 30,
    );
    var refletBottomRight1 = Offset(
      size.width / 2 + 28,
      size.height - vPadding - thickness - 30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(refletTopLeft1, refletBottomRight1),
        const Radius.circular(18),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          refletTopLeft1,
          refletTopLeft1 + const Offset(30, 0),
          [Colors.white10, Colors.white70],
          [0, 1],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    var refletTopLeft2 = Offset(
      size.width / 2 - 30,
      vPadding + thickness + 30,
    );
    var refletBottomRight2 = Offset(
      size.width / 2 - 12,
      size.height - vPadding - thickness - 30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(refletTopLeft2, refletBottomRight2),
        const Radius.circular(8),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          refletTopLeft2,
          refletTopLeft2 + const Offset(20, 0),
          [Colors.white10, Colors.white70],
          [0, 1],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawLiquid(
    ui.Canvas canvas,
    ui.Size size,
    ui.Offset bottomRight,
    ui.Offset topLeft,
  ) {
    const gradientColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.cyan,
    ];

    final lightColors = gradientColors.map((e) => e.withOpacity(.5)).toList();

    // liquid back
    final liquidTopLeft = Offset(
      (size.width - thermoWidth) / 2 + thickness,
      (size.height - radius - vPadding) -
          ((temperature / 50) * (size.height - (2 * vPadding + radius))),
    );

    final r = Rect.fromPoints(liquidTopLeft, bottomRight);
    final pathLight = Path()
      ..moveTo(r.topLeft.dx, r.topLeft.dy - (30 * (1 - animation)))
      ..lineTo(r.topRight.dx, r.topRight.dy - (30 * (animation)))
      ..lineTo(r.bottomRight.dx, r.bottomRight.dy)
      ..lineTo(r.bottomLeft.dx, r.bottomLeft.dy);

    final colorStops = List.generate(
      gradientColors.length,
      (index) => index / gradientColors.length,
    );

    canvas.drawPath(
      pathLight,
      Paint()
        ..shader = ui.Gradient.linear(
          topLeft,
          bottomRight,
          lightColors,
          colorStops,
        ),
    );

    // liquid
    final path = Path()
      ..moveTo(r.topLeft.dx, r.topLeft.dy - (30 * animation))
      ..lineTo(r.topRight.dx, r.topRight.dy - (30 * (1 - animation)))
      ..lineTo(r.bottomRight.dx, r.bottomRight.dy)
      ..lineTo(r.bottomLeft.dx, r.bottomLeft.dy);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          topLeft,
          bottomRight,
          gradientColors,
          colorStops,
        ),
    );

    /*canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(liquidTopLeft, bottomRight),
        bottomLeft: const Radius.circular(thermoWidth),
        bottomRight: const Radius.circular(thermoWidth),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          topLeft,
          bottomRight,
          gradientColors,
          colorStops,
        ),
    );*/
  }

  void drawContainer(
      ui.Canvas canvas, ui.Offset topLeft, ui.Offset bottomRight) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(topLeft, bottomRight),
        const Radius.circular(48),
      ),
      Paint()..color = Colors.grey.shade200,
    );
  }

  void _drawBackground(ui.Canvas canvas, ui.Size size) {
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, size.bottomRight(Offset.zero)),
      Paint()..color = Colors.grey.shade100,
    );
  }

  @override
  bool shouldRepaint(covariant ThermoPainter oldDelegate) {
    return oldDelegate.temperature != temperature ||
        oldDelegate.animation != animation;
  }
}
