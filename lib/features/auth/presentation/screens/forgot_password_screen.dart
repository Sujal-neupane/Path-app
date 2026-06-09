import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';
import 'package:path_app/core/components/clay_container.dart';
import 'package:path_app/features/auth/presentation/state/auth_state.dart';
import 'package:path_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:path_app/features/auth/presentation/widgets/auth_hero_section.dart';
import 'package:path_app/features/auth/presentation/widgets/trail_input_field.dart';
import 'package:path_app/features/auth/presentation/widgets/summit_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0 = Request Reset, 1 = Reset Confirm
  String? _autoRetrievedToken;
  String? _emailError;
  String? _tokenError;
  String? _passwordError;
  String? _confirmError;

  late AnimationController _staggerController;
  late Animation<double> _heroFade;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _heroFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _cardSlide = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.2, 0.7, curve: Curves.fastOutSlowIn),
    );
    _cardFade = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.1;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength.clamp(0.0, 1.0);
  }

  void _validateEmail(String val) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      if (val.trim().isEmpty) {
        _emailError = 'Email is required';
      } else if (!emailRegex.hasMatch(val.trim())) {
        _emailError = 'Invalid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validateToken(String val) {
    setState(() {
      if (val.trim().isEmpty) {
        _tokenError = 'Verification code is required';
      } else if (val.trim().length < 6) {
        _tokenError = 'Code must be 6 digits';
      } else {
        _tokenError = null;
      }
    });
  }

  void _validatePassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _passwordError = 'Password is required';
      } else if (val.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String val) {
    setState(() {
      if (val.isEmpty) {
        _confirmError = 'Please confirm password';
      } else if (val != _passwordController.text) {
        _confirmError = 'Passwords do not match';
      } else {
        _confirmError = null;
      }
    });
  }

  Future<void> _handleRequestCode() async {
    _validateEmail(_emailController.text);
    if (_emailError != null) return;

    final resultToken = await ref
        .read(authViewModelProvider.notifier)
        .requestPasswordReset(_emailController.text.trim());

    if (resultToken != null) {
      setState(() {
        _autoRetrievedToken = resultToken;
        _currentStep = 1;
      });
      _showTokenNotification(resultToken);
    }
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPass = _passwordController.text;

    _validateToken(token);
    _validatePassword(newPass);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_tokenError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    final success = await ref
        .read(authViewModelProvider.notifier)
        .resetPassword(email, token, newPass);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Redirecting to login...'),
          backgroundColor: LightColors.successGreen,
        ),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) context.go('/login');
      });
    }
  }

  void _showTokenNotification(String token) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.vpn_key_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'DEMO CODE: Generated reset token is "$token". Tap to copy.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: LightColors.peakAmber,
        duration: const Duration(seconds: 12),
        action: SnackBarAction(
          label: 'COPY',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: token));
          },
        ),
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
              tagline: 'SECURE CREDENTIAL RECOVERY',
              height: size.height * 0.35,
              parentController: _staggerController,
            ),
          ),

          // Back Button
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: ClayContainer(
                padding: const EdgeInsets.all(10),
                depth: 4,
                spread: 2,
                borderRadius: 14,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: LightColors.summitDark,
                  size: 20,
                ),
              ),
            ),
          ),

          // ── 2. Claymorphic Form Card ──
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
                  height: size.height * 0.70,
                  decoration: const BoxDecoration(
                    color: LightColors.stoneWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      36,
                      24,
                      20 + bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentStep == 0 ? 'Forgot\nPassword?' : 'Reset\nPassword',
                          style: AppTextStyles.h1.copyWith(
                            color: LightColors.summitDark,
                            fontSize: 34,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentStep == 0
                              ? 'Enter your email address to receive a 6-digit recovery code.'
                              : 'We have sent a verification code to your email. Set a new password below.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: LightColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Banner
                        if (authState is AuthError)
                          _buildErrorBanner(authState.message),

                        // Animated Step Switcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _currentStep == 0
                              ? _buildStepRequestCode(authState)
                              : _buildStepResetPassword(authState),
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

  Widget _buildStepRequestCode(AuthState authState) {
    return Column(
      key: const ValueKey('step_request'),
      children: [
        ClayContainer(
          depth: 6,
          spread: 3,
          borderRadius: 20,
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: TrailInputField(
            label: 'EMAIL',
            hint: 'your@email.com',
            icon: Icons.alternate_email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: _validateEmail,
          ),
        ),
        const SizedBox(height: 30),
        SummitButton(
          label: 'SEND CODE',
          isLoading: authState is AuthLoading,
          onPressed: _handleRequestCode,
        ),
      ],
    );
  }

  Widget _buildStepResetPassword(AuthState authState) {
    final strength = _getPasswordStrength(_passwordController.text);
    final strengthColor = strength < 0.4
        ? LightColors.sosRed
        : strength < 0.7
            ? LightColors.peakAmber
            : LightColors.successGreen;

    final strengthLabel = strength < 0.4
        ? 'Weak Altitude Protection'
        : strength < 0.7
            ? 'Moderate Elevation Protection'
            : 'Summit Grade Protection';

    return Column(
      key: const ValueKey('step_confirm'),
      children: [
        if (_autoRetrievedToken != null)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _autoRetrievedToken!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard!')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: LightColors.peakAmber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LightColors.peakAmber.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.copy_rounded, color: LightColors.peakAmber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Local Dev Code: ${_autoRetrievedToken!} (Tap to copy)',
                      style: const TextStyle(
                        color: LightColors.peakAmber,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ClayContainer(
          depth: 6,
          spread: 3,
          borderRadius: 22,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              TrailInputField(
                label: 'VERIFICATION CODE',
                hint: 'Enter 6-digit code',
                icon: Icons.vpn_key_outlined,
                controller: _tokenController,
                keyboardType: TextInputType.number,
                errorText: _tokenError,
                onChanged: _validateToken,
              ),
              const SizedBox(height: 16),
              TrailInputField(
                label: 'NEW PASSWORD',
                hint: 'Min 8 characters',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                controller: _passwordController,
                errorText: _passwordError,
                onChanged: (val) {
                  _validatePassword(val);
                  setState(() {}); // Redraw strength bar
                },
              ),
              const SizedBox(height: 8),

              // Tactical password altitude-strength bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strengthLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: strengthColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          '${(strength * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: strengthColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 6,
                        width: double.infinity,
                        color: LightColors.stoneWhite,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (strength * 100).toInt(),
                              child: Container(color: strengthColor),
                            ),
                            Expanded(
                              flex: (100 - (strength * 100)).toInt(),
                              child: Container(color: Colors.transparent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TrailInputField(
                label: 'CONFIRM NEW PASSWORD',
                hint: 'Re-enter password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                controller: _confirmPasswordController,
                errorText: _confirmError,
                onChanged: _validateConfirmPassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SummitButton(
          label: 'RESET PASSWORD',
          isLoading: authState is AuthLoading,
          isSuccess: authState is AuthSuccess,
          onPressed: _handleResetPassword,
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
              _autoRetrievedToken = null;
            });
          },
          child: const Text(
            'Request new code',
            style: TextStyle(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LightColors.sosRed.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LightColors.sosRed.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: LightColors.sosRed),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: LightColors.sosRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
