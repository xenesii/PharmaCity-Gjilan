import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 54,
    this.width,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _animController.forward(),
      onTapUp: isDisabled ? null : (_) => _animController.reverse(),
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: widget.isOutlined
              ? _buildOutlinedButton(isDisabled)
              : _buildFilledButton(isDisabled),
        ),
      ),
    );
  }

  Widget _buildFilledButton(bool isDisabled) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        splashColor: AppColors.white.withValues(alpha: 0.2),
        highlightColor: AppColors.white.withValues(alpha: 0.1),
        child: Container(
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? AppColors.border : null,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: widget.foregroundColor ?? AppColors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.buttonText.copyWith(
                          color: isDisabled ? AppColors.textHint : (widget.foregroundColor ?? AppColors.white),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(bool isDisabled) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled ? AppColors.border : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 20, color: widget.foregroundColor ?? AppColors.primary),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.buttonText.copyWith(
                          color: isDisabled ? AppColors.textHint : (widget.foregroundColor ?? AppColors.primary),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
