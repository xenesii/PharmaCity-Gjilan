import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final List<String>? autofillHints;
  final int? maxLines;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autofillHints,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isFocused = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode!.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode!.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          autofillHints: widget.autofillHints,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 6),
                    child: widget.prefixIcon,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled ? AppColors.surfaceVariant : AppColors.borderLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            labelStyle: TextStyle(
              color: _isFocused ? AppColors.primary : AppColors.textHint,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
            prefixIconColor: _isFocused ? AppColors.primary : AppColors.textHint,
            suffixIconColor: _isFocused ? AppColors.primary : AppColors.textHint,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
