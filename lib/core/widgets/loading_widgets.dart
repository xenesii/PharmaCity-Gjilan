import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Premium shimmer widget for skeleton loading
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.surfaceVariant,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Premium product card shimmer
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: const ShimmerWidget(height: 150, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(height: 14, width: 120),
                const SizedBox(height: 8),
                const ShimmerWidget(height: 12, width: 80),
                const SizedBox(height: 8),
                const ShimmerWidget(height: 16, width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium list shimmer
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const ListShimmer({super.key, this.itemCount = 6, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => const ProductCardShimmer(),
      );
    }
    return Column(
      children: List.generate(itemCount, (i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          const ShimmerWidget(width: 80, height: 80, borderRadius: 14),
          const SizedBox(width: 14),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget(height: 14, width: 160),
              SizedBox(height: 8),
              ShimmerWidget(height: 12, width: 100),
              SizedBox(height: 8),
              ShimmerWidget(height: 16, width: 60),
            ],
          )),
        ]),
      )),
    );
  }
}

/// Premium error widget
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, this.message = 'Something went wrong', this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inventory_2_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 48),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Premium loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({super.key, required this.isLoading, required this.child, this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.shadowHeavy,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowHeavy,
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Premium section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge,
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Premium price display
class PriceDisplay extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final TextStyle? priceStyle;
  final TextStyle? oldPriceStyle;

  const PriceDisplay({
    super.key,
    required this.price,
    this.discountPrice,
    this.priceStyle,
    this.oldPriceStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (discountPrice != null && discountPrice! < price) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${discountPrice!.toStringAsFixed(2)}',
            style: priceStyle ?? AppTextStyles.priceText,
          ),
          const SizedBox(width: 6),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: oldPriceStyle ?? const TextStyle(
              fontSize: 13,
              decoration: TextDecoration.lineThrough,
              color: AppColors.textHint,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
    }
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: priceStyle ?? AppTextStyles.priceText,
    );
  }
}

/// Premium animated counter widget
class AnimatedCounter extends StatelessWidget {
  final int count;
  final double size;

  const AnimatedCounter({super.key, required this.count, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: Container(
        key: ValueKey(count),
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$count',
            style: TextStyle(
              color: AppColors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
