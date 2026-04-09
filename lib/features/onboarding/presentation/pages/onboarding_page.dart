import 'package:flutter/material.dart';
import 'package:path_app/features/auth/presentation/screens/login_screen.dart';

import '../../../../core/theme/light_colors.dart';
import '../widgets/onboarding_item.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  double _pageOffset = 0.0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Smart Itineraries',
      'subtitle': 'Your virtual sherpa. We generate personalized climbing routes based on your fitness, budget, and time.',
      'lottieAsset': 'assets/animation/planning.json', 
      'icon': Icons.map_rounded,
    },
    {
      'title': 'Offline Navigation',
      'subtitle': 'Lose signal, not your way. Download topographic maps and let our character guide you precisely to the next teahouse.',
      'lottieAsset': 'assets/animation/traveller.json',
      'icon': Icons.explore_rounded,
    },
    {
      'title': 'Trek Safely',
      'subtitle': 'Built-in SOS, altitude sickness alerts, and live trail conditions ensure you reach the summit with complete peace of mind.',
      'lottieAsset': 'assets/animation/Sos Notification.json', 
      'icon': Icons.landscape_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())); //
        const SnackBar(
          content: Text('Transitioning to Authentication Flow...'),
          backgroundColor: LightColors.forestPrimary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.surfaceWhite, // Base white
      body: Stack(
        children: [
          // Background organic curves restricted to the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.35, // Only top part
            child: CustomPaint(
              painter: _ContinuousFlowPainter(
                pageOffset: _pageOffset,
                pageCount: _pages.length,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentIndex < _pages.length - 1 ? 1.0 : 0.0,
                    child: TextButton(
                      onPressed: () => _pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: LightColors.forestPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double itemOffset = 0.0;
                          if (_pageController.position.haveDimensions) {
                            itemOffset = (_pageController.page ?? 0) - index;
                          }
                          return OnboardingItem(
                            title: _pages[index]['title'],
                            subtitle: _pages[index]['subtitle'],
                            lottieAsset: _pages[index]['lottieAsset'],
                            fallbackIcon: _pages[index]['icon'],
                            pageOffset: itemOffset,
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentIndex == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? LightColors.forestPrimary 
                                  : LightColors.forestPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        width: _currentIndex == _pages.length - 1 ? 160 : 64,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.forestPrimary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: _currentIndex == _pages.length - 1
                            ? const Text(
                                "Let's Explore",
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinuousFlowPainter extends CustomPainter {
  final double pageOffset;
  final int pageCount;

  _ContinuousFlowPainter({required this.pageOffset, required this.pageCount});

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant, soft background layer behind the lottie
    final paint = Paint()
      ..color = LightColors.meadowTint.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    double totalWidth = size.width * pageCount;
    // Parallax panning effect
    double panX = -(pageOffset * size.width * 0.6);

    // Start drawing the organic shape from top left
    path.moveTo(panX, 0);

    // Flowing top wave that dips into the screen
    path.lineTo(panX, size.height * 0.4);

    // Flowing bottom edge
    path.quadraticBezierTo(
      panX + size.width * 0.5, size.height * 0.6 - math.sin(pageOffset * math.pi) * 30,
      panX + size.width * 1.0, size.height * 0.45
    );

    path.quadraticBezierTo(
      panX + size.width * 1.5, size.height * 0.3 + math.cos(pageOffset * math.pi) * 40,
      panX + size.width * 2.0, size.height * 0.5
    );

    path.quadraticBezierTo(
      panX + size.width * 2.5, size.height * 0.6,
      panX + size.width * 3.0, size.height * 0.4
    );

    // Close the shape along the top
    path.lineTo(panX + totalWidth, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Secondary lighter wave underneath
    final paintAccent = Paint()
      ..color = LightColors.trailGreen.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final pathAccent = Path();
    double panXAccent = -(pageOffset * size.width * 0.8);

    pathAccent.moveTo(panXAccent, 0);
    pathAccent.lineTo(panXAccent, size.height * 0.6);
    pathAccent.quadraticBezierTo(
      panXAccent + size.width * 0.8, size.height * 0.3 + math.sin(pageOffset * 2) * 50,
      panXAccent + size.width * 1.5, size.height * 0.65
    );
    pathAccent.quadraticBezierTo(
      panXAccent + size.width * 2.5, size.height * 0.4,
      panXAccent + size.width * 3.5, size.height * 0.5
    );
    pathAccent.lineTo(panXAccent + totalWidth, 0);
    pathAccent.close();

    canvas.drawPath(pathAccent, paintAccent);
    
    // Abstract sun/moon floating in the background
    final sunPaint = Paint()
      ..color = LightColors.peakAmber.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    // The sun moves horizontally across the screens
    double sunX = size.width * 0.3 - (pageOffset * size.width * 0.4);
    double sunY = size.height * 0.25 + math.sin(pageOffset * math.pi) * 20;
    
    canvas.drawCircle(Offset(sunX, sunY), size.width * 0.18, sunPaint);
  }

  @override
  bool shouldRepaint(covariant _ContinuousFlowPainter oldDelegate) {
    return oldDelegate.pageOffset != pageOffset;
  }
}
