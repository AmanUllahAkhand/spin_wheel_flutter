import 'dart:math';
import 'package:flutter/material.dart';


import '../../../../core/constants/app_color.dart';
import '../../../../core/utils/app_utils.dart';

class SpinWheelController {
  VoidCallback? _onSpin;

  void registerOnSpin(VoidCallback onSpin) {
    _onSpin = onSpin;
  }

  void spin() {
    _onSpin?.call();
  }
}

class SpinWheelWidget extends StatefulWidget {
  const SpinWheelWidget({
    super.key,
    required this.controller,
    required this.wheelSize,
    required this.values,
    this.textStyle,
    this.onSpinEnd,
  });

  final SpinWheelController controller;
  final double wheelSize;
  final List<String> values;
  final TextStyle? textStyle;
  final void Function(String)? onSpinEnd;

  @override
  State<SpinWheelWidget> createState() => _SpinWheelWidgetState();
}

class _SpinWheelWidgetState extends State<SpinWheelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _animation;
  final Random _random = Random();
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    widget.controller.registerOnSpin(spinWheel);
  }

  /// Spins the wheel with animation and calculates the result
  void spinWheel() {
    final double randomAngle =
        AppUtils.radianFor360 * (5 + _random.nextDouble() * 2);
    final double newRotation = _currentRotation + randomAngle;

    _animation = Tween<double>(
      begin: _currentRotation,
      end: newRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _animation!.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentRotation = _animation!.value % AppUtils.radianFor360;
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        final sliceAngle = AppUtils.radianFor360 / widget.values.length;
        final adjustedRotation = (_currentRotation) % AppUtils.radianFor360;

        // Calculate selected index
        int index = (adjustedRotation / sliceAngle).floor();
        index = widget.values.length - 1 - index;
        if (index < 0) index += widget.values.length;
        final selectedValue = widget.values[index];
        widget.onSpinEnd?.call(selectedValue);
      }
    });

    _controller.reset();
    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.wheelSize,
      width: widget.wheelSize,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The spinning wheel
            AnimatedBuilder(
              animation: _animation ?? _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation?.value ?? 0,
                  child: child,
                );
              },
              child: SizedBox(
                height: widget.wheelSize,
                width: widget.wheelSize,
                child: CustomPaint(
                  painter: WheelPainter(
                    widget.values.length,
                    widget.values,
                    widget.textStyle ?? const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: ClipPath(
                clipper: BottomArrowClipper(),
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing the spinning wheel
class WheelPainter extends CustomPainter {
  final int slices;
  final List<String> values;
  final TextStyle textStyle;

  WheelPainter(this.slices, this.values, this.textStyle);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sweepAngle = AppUtils.radianFor360 / slices;
    final List<Color> colors = [AppColor.danger, AppColor.success, AppColor.warning];

    for (int i = 0; i < slices; i++) {
      // Draw colored slice
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i * sweepAngle) - AppUtils.radianFor90,
        sweepAngle,
        true,
        paint,
      );

      // Draw value in white
      final double angle = (i + 0.5) * sweepAngle - AppUtils.radianFor90;

      final textSpan = TextSpan(
        text: values[i],
        style: textStyle.copyWith(color: Colors.white),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final double textRadius = radius * 0.65;
      final Offset offset = Offset(
        center.dx + textRadius * cos(angle) - textPainter.width / 2,
        center.dy + textRadius * sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Creates the arrow shape at the top
class BottomArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double arrowWidth = size.width;
    final double arrowHeight = size.height;

    path.moveTo(0, 0);
    path.lineTo(arrowWidth / 2, arrowHeight);
    path.lineTo(arrowWidth, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

