import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:path_app/features/auth/presentation/widgets/trail_input_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
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
          // 1. Unified Forest Header
          Container(
            height: size.height * 0.32,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [LightColors.forestPrimary, Color(0xFF1B4332)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RegisterTopoPainter(),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 32,
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join the Expedition',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Gear up for your next peak.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Registration Gear List
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.72,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    TrailInputField(
                      label: 'TREKKER NAME',
                      hint: 'What should we call you?',
                      icon: Icons.person_add_alt_1_outlined,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 18),
                    TrailInputField(
                      label: 'CONTACT SIGNAL (EMAIL)',
                      hint: 'For offline updates',
                      icon: Icons.alternate_email,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 18),
                    TrailInputField(
                      label: 'PHONE CHANNEL',
                      hint: '+1 expedition-line',
                      icon: Icons.phone_callback_outlined,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 18),
                    TrailInputField(
                      label: 'SAFE PASS (PASSWORD)',
                      hint: 'Protect your trail keys',
                      icon: Icons.vpn_key_outlined,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 48),
                    
                    // 3. Action Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authState is AuthLoading 
                          ? null 
                          : () {
                              ref.read(authViewModelProvider.notifier).register(
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            },
                        borderRadius: BorderRadius.circular(22),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [LightColors.forestPrimary, Color(0xFF2D6A4F)],
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
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'EQUIP & REGISTER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By registering, you agree to our Trail Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: LightColors.forestPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterTopoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final color = Colors.white.withValues(alpha: 0.08);

    for (int i = 0; i < 10; i++) {
      paint.color = color.withValues(alpha: (0.1 - (i * 0.01)));
      final path = Path();
      final shift = i * 20.0;

      path.moveTo(size.width, 0 + shift);
      path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.5 + shift,
        size.width * 0.4, size.height * 0.2 + shift,
      );
      path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.1 + shift,
        0, size.height * 0.4 + shift,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
