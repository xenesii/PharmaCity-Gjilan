import 'package:flutter/material.dart';

import '../app_colors.dart';

class PillTextFormField extends StatefulWidget {
  const PillTextFormField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  State<PillTextFormField> createState() => _PillTextFormFieldState();
}

class _PillTextFormFieldState extends State<PillTextFormField> {
  bool _hovered = false;
  bool _focused = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final fill = _focused
        ? const Color(0xFFE9E9E9)
        : _hovered
            ? const Color(0xFFD5D5D5)
            : const Color(0xFFCBCBCD);
    final borderColor = _focused
        ? AppColors.primary.withValues(alpha: 0.55)
        : _hovered
            ? const Color(0xFFB9B9BC)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      cursor: SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            if (_hovered || _focused)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Focus(
          onFocusChange: (value) {
            if (_focused == value) return;
            setState(() => _focused = value);
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: fill,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              prefixIcon: Icon(widget.icon, size: 20, color: Colors.black87),
              suffixIcon: widget.suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(999),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(999),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.25),
                borderRadius: BorderRadius.circular(999),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
                borderRadius: BorderRadius.circular(999),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.25),
                borderRadius: BorderRadius.circular(999),
              ),
              errorStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }
}

