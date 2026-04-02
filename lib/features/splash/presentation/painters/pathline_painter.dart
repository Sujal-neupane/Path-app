import 'package:flutter/material.dart';

class PathLinePainter extends CustomPainter {
  final Animation<double> progress;

  PathLinePainter({required this.progress}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paintMountain = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final pathMountain = Path();

    pathMountain.moveTo(0, size.height);
    pathMountain.lineTo(size.width / 2, 0);
    pathMountain.lineTo(size.width, size.height);
    pathMountain.close();

    canvas.drawPath(pathMountain, paintMountain);

    // Path line animation
    final paintLine = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pathLine = Path();
    pathLine.moveTo(size.width / 2, size.height - 20);

    final animatedHeight =
        (size.height - 20) - (progress.value * (size.height - 40));

    pathLine.lineTo(size.width / 2, animatedHeight);

    canvas.drawPath(pathLine, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
