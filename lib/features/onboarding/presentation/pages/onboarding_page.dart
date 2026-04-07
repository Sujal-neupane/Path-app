import 'package:flutter/material.dart';
import '../../../../core/theme/light_colors.dart';
import '../widgets/onboarding_item.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Home or Auth depending on logic
      // context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.summitDark, // Rich dark forest background
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: const [
              OnboardingItem(
                title: 'Discover Your Path',
                subtitle: 'Find the perfect trails tailored for your skill level.',
                iconData: Icons.map_outlined, // Use custom SVGs later
              ),
              OnboardingItem(
                title: 'Navigate with Confidence',
                subtitle: 'Download maps and stay on course, even when off-grid.',
                iconData: Icons.explore_outlined,
              ),
              OnboardingItem(
                title: 'Conquer the Summit',
                subtitle: 'Track your progress and share your wildest adventures.',
                iconData: Icons.landscape_outlined,
              ),
            ],
          ),
          
          // Bottom Navigation / Action Area
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button (Hide on last page)
                _currentIndex < 2
                    ? TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox(width: 64), // Placeholder to keep alignment
                
                // Active Page Indicator Dots
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? LightColors.peakAmber    // Active Dot
                            : Colors.white38,          // Inactive Dot
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next / Get Started Button
                ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightColors.forestPrimary, // Primary brand
                    foregroundColor: LightColors.logoWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    _currentIndex == 2 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
