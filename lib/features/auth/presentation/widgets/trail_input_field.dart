import 'package:flutter/material.dart';
import 'package:path_app/core/theme/light_colors.dart';

class TrailInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const TrailInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });

  @override
  State<TrailInputField> createState() => _TrailInputFieldState();
}

class _TrailInputFieldState extends State<TrailInputField> with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _trailController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _trailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _focusNode.addListener(() {
      setState(() {}); // Update to show/hide trail indicator
    });
  }

  @override
  void dispose() {
    _trailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: LightColors.forestPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              if (_focusNode.hasFocus)
                AnimatedBuilder(
                  animation: _trailController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: (0.5 + 0.5 * (1.0 - _trailController.value)),
                      child: const Text(
                        'FOLLOWING TRAIL 👣',
                        style: TextStyle(
                          color: LightColors.forestPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _focusNode.hasFocus 
              ? [BoxShadow(color: LightColors.forestPrimary.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]
              : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            obscuringCharacter: '•',
            validator: widget.validator,
            cursorColor: LightColors.forestPrimary,
            style: const TextStyle(
              color: LightColors.forestPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: LightColors.forestPrimary.withValues(alpha: 0.3),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: _focusNode.hasFocus ? LightColors.forestPrimary : LightColors.forestPrimary.withValues(alpha: 0.4),
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: LightColors.forestPrimary.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: LightColors.forestPrimary.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: LightColors.forestPrimary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
