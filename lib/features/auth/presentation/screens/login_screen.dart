import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:path_app/features/auth/presentation/widgets/trail_input_field.dart';
import 'package:path_app/features/auth/presentation/screens/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _mainController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _formAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: LightColors.surfaceWhite,
      body: Stack(
        children: [
          // 1. Dynamic Topographic Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: CustomPaint(
              painter: _TopographicPainter(),
            ),
          ),

          // 2. Immersive Logo & Title
          Positioned(
            top: size.height * 0.12,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _logoAnimation,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12), // Tighter padding for logo
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: LightColors.forestPrimary.withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.terrain,
                          size: 80,
                          color: LightColors.forestPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PATH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. User Interaction Surface (White Card)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_formAnimation),
              child: FadeTransition(
                opacity: _formAnimation,
                child: Container(
                  height: size.height * 0.58,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 40,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resume Expedition',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: LightColors.forestPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your offline maps are waiting for you.',
                          style: TextStyle(
                            fontSize: 15,
                            color: LightColors.forestPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 36),
                        TrailInputField(
                          label: 'EXPEDITION ID (EMAIL)',
                          hint: 'trekker@basecamp.com',
                          icon: Icons.alternate_email,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        TrailInputField(
                          label: 'TRAIL PASS (PASSWORD)',
                          hint: 'Your private key',
                          icon: Icons.key_outlined,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 40),
                        
                        // 4. Primary Adventure Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: authState is AuthLoading
                                ? null
                                : () {
                                    ref.read(authViewModelProvider.notifier).login(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                        );
                                  },
                            borderRadius: BorderRadius.circular(22),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: authState is AuthLoading 
                                      ? [Colors.grey.shade400, Colors.grey.shade500]
                                      : [LightColors.forestPrimary, const Color(0xFF1B4332)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: LightColors.forestPrimary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: authState is AuthLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'START CLIMB',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No gear yet? ',
                              style: TextStyle(
                                color: LightColors.forestPrimary.withValues(alpha: 0.5),
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                              child: const Text(
                                'Equip Here',
                                style: TextStyle(
                                  color: LightColors.forestPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopographicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LightColors.forestPrimary
      ..style = PaintingStyle.fill;

    // 1. Deep Background Fill
    final fillPath = Path();
    fillPath.moveTo(0, 0);
    fillPath.lineTo(size.width, 0);
    fillPath.lineTo(size.width, size.height * 0.4);
    fillPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.65,
      size.width * 0.4, size.height * 0.55,
    );
    fillPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.45,
      0, size.height * 0.7,
    );
    fillPath.close();
    canvas.drawPath(fillPath, paint);

    // 2. Animated Contour Lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 6; i++) {
      linePaint.color = Colors.white.withValues(alpha: (0.15 - (i * 0.02)));
      final path = Path();
      final shift = i * 22.0;

      path.moveTo(0, size.height * 0.75 - shift);
      path.quadraticBezierTo(
        size.width * 0.3, size.height * 0.5 - shift,
        size.width * 0.6, size.height * 0.8 - shift,
      );
      path.quadraticBezierTo(
        size.width * 0.85, size.height * 1.0 - shift,
        size.width, size.height * 0.6 - shift,
      );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
