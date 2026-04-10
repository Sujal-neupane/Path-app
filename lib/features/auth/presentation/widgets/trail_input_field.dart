import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';
import 'package:path_app/core/theme/app_text_styles.dart';

/// A trail-themed input field with creative micro-interactions:
///
/// - **Progressive border glow**: Border brightens as user types
/// - **Label color shift**: Label darkens when focused
/// - **Validation feedback**: Error shake + red indicator; success checkmark
/// - **Icon morphing**: Prefix icon scales on focus
class TrailInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const TrailInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.errorText,
    this.onChanged,
    this.keyboardType,
  });

  @override
  State<TrailInputField> createState() => _TrailInputFieldState();
}

class _TrailInputFieldState extends State<TrailInputField>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _hasText = false;
  final FocusNode _focusNode = FocusNode();

  late AnimationController _focusAnimController;
  late AnimationController _trailWalkController;
  late AnimationController _shakeController;
  late Animation<double> _focusAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _focusAnimation = CurvedAnimation(
      parent: _focusAnimController,
      curve: Curves.easeOutCubic,
    );

    _trailWalkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.02, 0), end: const Offset(-0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-0.02, 0), end: const Offset(0.015, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(0.015, 0), end: const Offset(-0.01, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.01, 0), end: Offset.zero),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusAnimController.forward();
      _trailWalkController.repeat();
    } else {
      _focusAnimController.reverse();
      _trailWalkController.stop();
    }
    setState(() {});
  }

  void _onTextChange() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void didUpdateWidget(TrailInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    _trailWalkController.dispose();
    _shakeController.dispose();
    _focusNode.dispose();
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return SlideTransition(
      position: _shakeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label Row ──
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTextStyles.fieldLabel.copyWith(
                    color: hasError
                        ? LightColors.sosRed
                        : isFocused
                            ? LightColors.summitDark
                            : const Color(0xFF757575),
                  ),
                  child: Text(widget.label),
                ),
                // Animated trail indicator (dots only, no emoji)
                if (isFocused)
                  AnimatedBuilder(
                    animation: _trailWalkController,
                    builder: (context, _) {
                      return _buildTrailIndicator();
                    },
                  ),
              ],
            ),
          ),

          // ── Input Field ──
          AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (isFocused && !hasError)
                      BoxShadow(
                        color: LightColors.forestPrimary
                            .withValues(alpha: 0.06 * _focusAnimation.value),
                        blurRadius: 20 * _focusAnimation.value,
                        offset: const Offset(0, 6),
                      ),
                    if (hasError)
                      BoxShadow(
                        color: LightColors.sosRed.withValues(alpha: 0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: child,
              );
            },
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isPassword ? _obscureText : false,
              obscuringCharacter: '·',
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              cursorColor: LightColors.summitDark,
              cursorHeight: 20,
              onChanged: widget.onChanged,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'Inter',
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
                prefixIcon: AnimatedBuilder(
                  animation: _focusAnimation,
                  builder: (context, _) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: AnimatedScale(
                        scale: isFocused ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.icon,
                          color: hasError
                              ? LightColors.sosRed.withValues(alpha: 0.7)
                              : Color.lerp(
                                  const Color(0xFFAAAAAA),
                                  LightColors.summitDark,
                                  _focusAnimation.value,
                                ),
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            key: ValueKey(_obscureText),
                            color: const Color(0xFFAAAAAA),
                            size: 20,
                          ),
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      )
                    : (_hasText && !hasError && !isFocused)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              builder: (context, value, _) {
                                return Transform.scale(
                                  scale: value,
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: LightColors.trailGreen
                                        .withValues(alpha: 0.6),
                                    size: 18,
                                  ),
                                );
                              },
                            ),
                          )
                        : null,
                filled: true,
                fillColor: isFocused
                    ? Colors.white
                    : const Color(0xFFF8F8F8),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError
                        ? LightColors.sosRed.withValues(alpha: 0.3)
                        : const Color(0xFFE8E8E8),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: hasError
                        ? LightColors.sosRed
                        : LightColors.summitDark,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Error Message ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: hasError
                ? Padding(
                    padding: const EdgeInsets.only(left: 4, top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 13,
                            color: LightColors.sosRed.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.errorText!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: LightColors.sosRed.withValues(alpha: 0.8),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Trail indicator: animated dots (no emoji).
  Widget _buildTrailIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing trail text
        AnimatedBuilder(
          animation: _trailWalkController,
          builder: (context, child) {
            final pulse = 0.5 +
                0.5 *
                    math.sin(
                        _trailWalkController.value * math.pi * 2);
            return Opacity(opacity: pulse, child: child);
          },
          child: Text(
            'ACTIVE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: LightColors.forestPrimary.withValues(alpha: 0.6),
              letterSpacing: 1.0,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Walking dots
        ...List.generate(3, (i) {
          final phase =
              (_trailWalkController.value * math.pi * 2 + i * 0.8) %
                  (math.pi * 2);
          final opacity = 0.3 + 0.7 * ((math.sin(phase) + 1) / 2);
          return Container(
            margin: const EdgeInsets.only(right: 3),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: LightColors.forestPrimary.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ],
    );
  }
}
