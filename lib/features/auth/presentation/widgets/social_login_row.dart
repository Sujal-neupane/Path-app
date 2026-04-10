import 'package:flutter/material.dart';

/// Social login options (Google, Apple) with a clean "or" divider.
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Clean divider
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFEEEEEE),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFAAAAAA),
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFEEEEEE),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Social buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              label: 'Google',
              icon: Icons.g_mobiledata_rounded,
              onTap: () {
                // TODO: Google sign-in
              },
            ),
            const SizedBox(width: 16),
            _SocialButton(
              label: 'Apple',
              icon: Icons.apple,
              onTap: () {
                // TODO: Apple sign-in
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 72,
          height: 52,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFF5F5F5)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.01 : 0.03),
                blurRadius: _isPressed ? 4 : 10,
                offset: Offset(0, _isPressed ? 1 : 3),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 24,
            color: const Color(0xFF444444),
          ),
        ),
      ),
    );
  }
}
