import 'package:flutter/material.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PATH - Embark on Your Path',
      home: const Scaffold(
        backgroundColor: Color(0xFFF0F0F0), // --bg-off-white
        body: Center(child: WordmarkScreen()),
      ),
    );
  }
}

class WordmarkScreen extends StatelessWidget {
  const WordmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'P',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 80,
                letterSpacing: -1.5,
                color: const Color(0xFF2A2A2A),
              ),
            ),
            const SizedBox(width: 4),
            const MountainWidget(),
            const SizedBox(width: 4),
            Text(
              'T',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 80,
                letterSpacing: -1.5,
                color: Color(0xFF2A2A2A),
              ),
            ),
            Text(
              'H',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 80,
                letterSpacing: -1.5,
                color: Color(0xFF2A2A2A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Embark on Your Path.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: 3,
            fontSize: 14,
            color: Color(0xFF2A2A2A),
          ),
        ),
      ],
    );
  }
}

class MountainWidget extends StatelessWidget {
  const MountainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base Mountain
          ClipPath(
            clipper: MountainBaseClipper(),
            child: Container(color: const Color(0xFF2A2A2A)),
          ),
          // Ridge
          ClipPath(
            clipper: MountainRidgeClipper(),
            child: Container(
              color: const Color(0xFF0A0A0A).withOpacity(0.85),
            ),
          ),
          // Accent
          ClipPath(
            clipper: MountainAccentClipper(),
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),
          // Climber Icon
          Positioned(
            bottom: 2,
            child: Icon(
              Icons.hiking,
              color: const Color(0xFFF0F0F0),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for mountain base
class MountainBaseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Approximate polygon from CSS
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.58, size.height * 0.15);
    path.lineTo(size.width * 0.62, size.height * 0.28);
    path.lineTo(size.width * 0.61, size.height * 0.38);
    path.lineTo(size.width * 0.7, size.height * 0.52);
    path.lineTo(size.width * 0.82, size.height * 0.7);
    path.lineTo(size.width * 0.94, size.height * 0.88);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.08, size.height * 0.88);
    path.lineTo(size.width * 0.15, size.height * 0.75);
    path.lineTo(size.width * 0.28, size.height * 0.58);
    path.lineTo(size.width * 0.32, size.height * 0.45);
    path.lineTo(size.width * 0.36, size.height * 0.32);
    path.lineTo(size.width * 0.42, size.height * 0.18);
    path.lineTo(size.width * 0.46, size.height * 0.08);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Ridge Clipper
class MountainRidgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.52, size.height * 0.2);
    path.lineTo(size.width * 0.47, size.height * 0.35);
    path.lineTo(size.width * 0.52, size.height * 0.55);
    path.lineTo(size.width * 0.48, size.height * 0.78);
    path.lineTo(size.width * 0.51, size.height);
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.08, size.height * 0.88);
    path.lineTo(size.width * 0.15, size.height * 0.75);
    path.lineTo(size.width * 0.28, size.height * 0.58);
    path.lineTo(size.width * 0.32, size.height * 0.45);
    path.lineTo(size.width * 0.36, size.height * 0.32);
    path.lineTo(size.width * 0.42, size.height * 0.18);
    path.lineTo(size.width * 0.46, size.height * 0.08);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Accent Clipper
class MountainAccentClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.05);
    path.lineTo(size.width * 0.55, size.height * 0.25);
    path.lineTo(size.width * 0.53, size.height * 0.48);
    path.lineTo(size.width * 0.57, size.height * 0.72);
    path.lineTo(size.width * 0.52, size.height);
    path.lineTo(size.width * 0.46, size.height);
    path.lineTo(size.width * 0.44, size.height * 0.75);
    path.lineTo(size.width * 0.49, size.height * 0.42);
    path.lineTo(size.width * 0.43, size.height * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
