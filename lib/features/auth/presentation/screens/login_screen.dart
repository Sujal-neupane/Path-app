import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:path_app/features/auth/presentation/widgets/auth_hero_section.dart';
import 'package:path_app/features/auth/presentation/widgets/trail_input_field.dart';
import 'package:path_app/features/auth/presentation/widgets/summit_button.dart';
import 'package:path_app/features/auth/presentation/widgets/social_login_row.dart';
import 'package:path_app/features/auth/presentation/screens/register_screen.dart';
import 'package:path_app/features/dashboard/presentation/screens/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  late AnimationController _staggerController;
  late Animation<double> _heroFade;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;
  late Animation<double> _field1Slide;
  late Animation<double> _field2Slide;
  late Animation<double> _buttonFade;
  late Animation<double> _socialFade;

  @override
  void initState() {
    super.initState();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _heroFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _cardSlide = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.25, 0.65, curve: Curves.fastOutSlowIn),
    );
    _cardFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );
    _field1Slide = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.40, 0.70, curve: Curves.easeOutCubic),
    );
    _field2Slide = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOutCubic),
    );
    _buttonFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.60, 0.85, curve: Curves.easeOut),
    );
    _socialFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    ref.read(authViewModelProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ).then((_) {
          if (ref.read(authViewModelProvider) is AuthSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          }
        });
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: LightColors.stoneWhite,
      body: Stack(
        children: [
          // ── 1. Mountain Hero Header ──
          FadeTransition(
            opacity: _heroFade,
            child: AuthHeroSection(
              tagline: 'RESUME YOUR EXPEDITION',
              height: size.height * 0.38,
              parentController: _staggerController,
            ),
          ),

          // ── 2. White Form Card ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(_cardSlide),
              child: FadeTransition(
                opacity: _cardFade,
                child: Container(
                  height: size.height * 0.66,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 40,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(28, 36, 28, 20 + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Welcome Back,\nExplorer',
                          style: AppTextStyles.h1.copyWith(
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your offline maps are waiting for you.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: const Color(0xFF999999),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ── Email Field ──
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.12, 0),
                            end: Offset.zero,
                          ).animate(_field1Slide),
                          child: FadeTransition(
                            opacity: _field1Slide,
                            child: TrailInputField(
                              label: 'EMAIL',
                              hint: 'your@email.com',
                              icon: Icons.alternate_email_rounded,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              errorText: authState is AuthFormState
                                  ? authState.fieldErrors['email']
                                  : null,
                              onChanged: (val) => ref
                                  .read(authViewModelProvider.notifier)
                                  .validateField('email', val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Password Field ──
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.12, 0),
                            end: Offset.zero,
                          ).animate(_field2Slide),
                          child: FadeTransition(
                            opacity: _field2Slide,
                            child: TrailInputField(
                              label: 'PASSWORD',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              controller: _passwordController,
                              errorText: authState is AuthFormState
                                  ? authState.fieldErrors['password']
                                  : null,
                              onChanged: (val) => ref
                                  .read(authViewModelProvider.notifier)
                                  .validateField('password', val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Remember Me / Forgot Password ──
                        FadeTransition(
                          opacity: _buttonFade,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => setState(
                                    () => _rememberMe = !_rememberMe),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 250),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? LightColors.summitDark
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _rememberMe
                                              ? LightColors.summitDark
                                              : const Color(0xFFD0D0D0),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(Icons.check_rounded,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF888888),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // TODO: Forgot password flow
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Error Message ──
                        if (authState is AuthError)
                          _buildErrorBanner(authState.message),

                        // ── Summit Button ──
                        FadeTransition(
                          opacity: _buttonFade,
                          child: SummitButton(
                            label: 'SIGN IN',
                            isLoading: authState is AuthLoading,
                            isSuccess: authState is AuthSuccess,
                            onPressed: _handleLogin,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Social Login ──
                        FadeTransition(
                          opacity: _socialFade,
                          child: const SocialLoginRow(),
                        ),
                        const SizedBox(height: 24),

                        // ── Register Link ──
                        FadeTransition(
                          opacity: _socialFade,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              GestureDetector(
                                onTap: _navigateToRegister,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    fontFamily: 'PlusJakartaSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: LightColors.sosRed.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: LightColors.sosRed.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: LightColors.sosRed.withValues(alpha: 0.7), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: LightColors.sosRed.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
