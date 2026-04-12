import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:path_app/features/auth/presentation/widgets/trail_input_field.dart';
import 'package:path_app/features/auth/presentation/widgets/summit_button.dart';
import 'package:path_app/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:path_app/features/auth/presentation/widgets/auth_hero_section.dart';
import 'package:path_app/features/dashboard/presentation/screens/dashboard_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  int _currentStep = 0;

  late AnimationController _entryController;
  late AnimationController _progressController;

  late Animation<double> _headerFade;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _formFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final vm = ref.read(authViewModelProvider.notifier);
    vm.validateField('fullName', fullName);
    vm.validateField('email', email);

    final state = ref.read(authViewModelProvider);
    if (state is AuthFormState) {
      if (state.fieldErrors['fullName'] != null ||
          state.fieldErrors['email'] != null) {
        return;
      }
    }

    setState(() => _currentStep = 1);
    _progressController.animateTo(1.0, curve: Curves.easeOutCubic);
  }

  void _goToStep1() {
    setState(() => _currentStep = 0);
    _progressController.animateTo(0.0, curve: Curves.easeOutCubic);
  }

  void _handleRegister() {
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final vm = ref.read(authViewModelProvider.notifier);
    vm.validateField('phoneNumber', phoneNumber);
    vm.validateField('password', password);

    final state = ref.read(authViewModelProvider);
    if (state is AuthFormState) {
      if (state.fieldErrors['phoneNumber'] != null ||
          state.fieldErrors['password'] != null) {
        return;
      }
    }

    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();

    vm.register(fullName, email, phoneNumber, password).then((_) {
      if (ref.read(authViewModelProvider) is AuthSuccess) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    });
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
          // ── 1. Mountain Hero Header (same as login for consistency) ──
          FadeTransition(
            opacity: _headerFade,
            child: AuthHeroSection(
              tagline: 'JOIN THE EXPEDITION',
              height: size.height * 0.34,
              parentController: _entryController,
            ),
          ),

          // ── 2. Back button + Step indicator overlay ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 16,
            child: FadeTransition(
              opacity: _headerFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_currentStep > 0) {
                        _goToStep1();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  // Step pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'STEP ${_currentStep + 1} OF 2',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 3. White Form Card (consistent with login) ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_formFade),
              child: FadeTransition(
                opacity: _formFade,
                child: Container(
                  height: size.height * 0.70,
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
                  child: Column(
                    children: [
                      // Progress bar
                      _buildProgressBar(),

                      // Scrollable form
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            28,
                            24,
                            28,
                            20 + bottomPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step title
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  key: ValueKey(_currentStep),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentStep == 0
                                          ? 'Create Your\nAccount'
                                          : 'Almost\nThere',
                                      style: AppTextStyles.h1.copyWith(
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentStep == 0
                                          ? 'Start with your name and email.'
                                          : 'Add your phone and set a password.',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: const Color(0xFF999999),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // ── Step Content ──
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(
                                          _currentStep == 1 ? 0.1 : -0.1,
                                          0,
                                        ),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _currentStep == 0
                                    ? _buildStep1(authState)
                                    : _buildStep2(authState),
                              ),
                              const SizedBox(height: 28),

                              // ── Error Message ──
                              if (authState is AuthError)
                                _buildErrorBanner(authState.message),

                              // ── Action Button ──
                              SummitButton(
                                label: _currentStep == 0
                                    ? 'CONTINUE'
                                    : 'CREATE ACCOUNT',
                                isLoading: authState is AuthLoading,
                                isSuccess: authState is AuthSuccess,
                                onPressed: _currentStep == 0
                                    ? _goToStep2
                                    : _handleRegister,
                              ),
                              const SizedBox(height: 20),

                              // ── Bottom Links ──
                              if (_currentStep == 0)
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: Color(0xFF999999),
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: const Text(
                                          'Sign In',
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

                              if (_currentStep == 1)
                                Center(
                                  child: Text(
                                    'By creating an account, you agree to our Terms of Service.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFFAAAAAA),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress Bar (clean, no emojis) ──
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          final progress = _progressController.value;
          return Column(
            children: [
              // Step labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Info',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      fontFamily: 'Inter',
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: progress > 0.5
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFCCCCCC),
                      fontFamily: 'Inter',
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Track
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFF0F0F0),
                      ),
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        widthFactor: 0.5 + progress * 0.5,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: LightColors.summitDark,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Step 1: Name + Email ──
  Widget _buildStep1(AuthState authState) {
    return Column(
      key: const ValueKey('step1'),
      children: [
        TrailInputField(
          label: 'FULL NAME',
          hint: 'Enter your full name',
          icon: Icons.person_outline_rounded,
          controller: _nameController,
          errorText: authState is AuthFormState
              ? authState.fieldErrors['fullName']
              : null,
          onChanged: (val) => ref
              .read(authViewModelProvider.notifier)
              .validateField('fullName', val),
        ),
        const SizedBox(height: 18),
        TrailInputField(
          label: 'EMAIL ADDRESS',
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
      ],
    );
  }

  // ── Step 2: Phone + Password ──
  Widget _buildStep2(AuthState authState) {
    final passwordStrength = authState is AuthFormState
        ? authState.passwordStrength
        : 0.0;

    return Column(
      key: const ValueKey('step2'),
      children: [
        TrailInputField(
          label: 'PHONE NUMBER',
          hint: '+977 XXXXXXXXXX',
          icon: Icons.phone_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          errorText: authState is AuthFormState
              ? authState.fieldErrors['phoneNumber']
              : null,
          onChanged: (val) => ref
              .read(authViewModelProvider.notifier)
              .validateField('phoneNumber', val),
        ),
        const SizedBox(height: 18),
        TrailInputField(
          label: 'PASSWORD',
          hint: 'Create a password',
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
        PasswordStrengthIndicator(strength: passwordStrength),
      ],
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
          border: Border.all(color: LightColors.sosRed.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: LightColors.sosRed.withValues(alpha: 0.7),
              size: 18,
            ),
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

/// Animated FractionallySizedBox for the progress bar.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final AlignmentGeometry alignment;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.alignment,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor =
        visitor(
              _widthFactor,
              widget.widthFactor,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
