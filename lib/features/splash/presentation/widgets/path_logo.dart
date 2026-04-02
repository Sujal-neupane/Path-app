import 'package:flutter/material.dart';
import 'package:path_app/features/splash/presentation/painters/pathline_painter.dart';

class PathLogo  extends StatelessWidget{
  final AnimationController controller;

  const PathLogo({super.key, required this.controller});



  @override  
  Widget build(BuildContext context){
    return SizedBox(
      width: 200,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // mountain shape
          CustomPaint(
            size: const Size(200, 120),
            painter: PathLinePainter(progress: controller),
          ),

          // climber dor 
          AnimatedBuilder(
            animation: controller,
            builder: (_,__){
              final value = controller.value;

              return Positioned(
               bottom: 20 + (value * 40), // climbs up
                left: 95,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
