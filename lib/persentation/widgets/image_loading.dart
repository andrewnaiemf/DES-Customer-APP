import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Image Widget Colors
// ═══════════════════════════════════════════════════════════════════════════
class ImageColors {
  // Light Mode
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightShimmerBase = Color(0xFFE5E7EB);
  static const Color lightShimmerHighlight = Color(0xFFF9FAFB);
  static const Color lightIconColor = Color(0xFF9CA3AF);
  static const Color lightErrorBg = Color(0xFFFEE2E2);
  static const Color lightErrorIcon = Color(0xFFEF4444);

  // Dark Mode
  static const Color darkBackground = Color(0xFF1F2937);
  static const Color darkShimmerBase = Color(0xFF374151);
  static const Color darkShimmerHighlight = Color(0xFF4B5563);
  static const Color darkIconColor = Color(0xFF6B7280);
  static const Color darkErrorBg = Color(0xFF450A0A);
  static const Color darkErrorIcon = Color(0xFFF87171);

  // Brand Colors
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);

  // Helper methods
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color shimmerBase(bool isDark) =>
      isDark ? darkShimmerBase : lightShimmerBase;

  static Color shimmerHighlight(bool isDark) =>
      isDark ? darkShimmerHighlight : lightShimmerHighlight;

  static Color iconColor(bool isDark) => isDark ? darkIconColor : lightIconColor;

  static Color errorBg(bool isDark) => isDark ? darkErrorBg : lightErrorBg;

  static Color errorIcon(bool isDark) => isDark ? darkErrorIcon : lightErrorIcon;

  static Color accentColor(bool isDark) => isDark ? lightGreen : purple;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖼️ Network Image Widget - Premium Design
// ═══════════════════════════════════════════════════════════════════════════
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showLoadingProgress;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final bool enableShimmer;
  final IconData? errorIcon;
  final double? errorIconSize;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.showLoadingProgress = false,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.enableShimmer = true,
    this.errorIcon,
    this.errorIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? ImageColors.background(isDark),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          // ✅ تحسين الأداء: تقليل حجم الصورة في الذاكرة
          memCacheWidth: width != null ? (width! * 2).toInt() : null,
          memCacheHeight: height != null ? (height! * 2).toInt() : null,
          maxWidthDiskCache: 800, // ✅ الحد الأقصى لعرض الصورة المحفوظة
          maxHeightDiskCache: 800, // ✅ الحد الأقصى لارتفاع الصورة المحفوظة
          fadeInDuration: const Duration(milliseconds: 200), // ✅ تقليل مدة الظهور
          placeholder: (context, url) =>
              placeholder ?? _buildPlaceholder(isDark),
          progressIndicatorBuilder: showLoadingProgress
              ? (context, url, progress) =>
                  _buildProgressIndicator(isDark, progress)
              : null,
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildErrorWidget(isDark),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    if (enableShimmer) {
      return Shimmer.fromColors(
        baseColor: ImageColors.shimmerBase(isDark),
        highlightColor: ImageColors.shimmerHighlight(isDark),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: ImageColors.background(isDark),
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: ImageColors.background(isDark),
      child: Center(
        child: _AnimatedLoadingIcon(isDark: isDark),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark, DownloadProgress progress) {
    return Container(
      width: width,
      height: height,
      color: ImageColors.background(isDark),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer background
          if (enableShimmer)
            Shimmer.fromColors(
              baseColor: ImageColors.shimmerBase(isDark),
              highlightColor: ImageColors.shimmerHighlight(isDark),
              child: Container(
                width: width,
                height: height,
                color: ImageColors.background(isDark),
              ),
            ),
          // Progress indicator
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress.progress,
                  strokeWidth: 3,
                  backgroundColor: ImageColors.iconColor(isDark).withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ImageColors.accentColor(isDark),
                  ),
                ),
              ),
              if (progress.progress != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress.progress! * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ImageColors.iconColor(isDark),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ImageColors.errorBg(isDark),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ImageColors.errorIcon(isDark).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              errorIcon ?? Icons.broken_image_rounded,
              size: errorIconSize ?? 20,
              color: ImageColors.errorIcon(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: ImageColors.errorIcon(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📁 File Image Widget
// ═══════════════════════════════════════════════════════════════════════════
class AppFileImage extends StatelessWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AppFileImage({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final file = File(filePath);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? ImageColors.background(isDark),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: file.existsSync()
            ? Image.file(
                file,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (context, error, stackTrace) =>
                    errorWidget ?? _buildErrorWidget(isDark),
              )
            : errorWidget ?? _buildErrorWidget(isDark),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ImageColors.errorBg(isDark),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ImageColors.errorIcon(isDark).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 28,
              color: ImageColors.errorIcon(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'File not found',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ImageColors.errorIcon(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎭 Asset Image Widget
// ═══════════════════════════════════════════════════════════════════════════
class AppAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? color;

  const AppAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) =>
              _buildErrorWidget(isDark),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: ImageColors.errorBg(isDark),
      child: Icon(
        Icons.broken_image_rounded,
        size: 28,
        color: ImageColors.errorIcon(isDark),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✨ Animated Loading Icon
// ═══════════════════════════════════════════════════════════════════════════
class _AnimatedLoadingIcon extends StatefulWidget {
  final bool isDark;

  const _AnimatedLoadingIcon({required this.isDark});

  @override
  State<_AnimatedLoadingIcon> createState() => _AnimatedLoadingIconState();
}

class _AnimatedLoadingIconState extends State<_AnimatedLoadingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ImageColors.accentColor(widget.isDark).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.image_rounded,
                size: 24,
                color: ImageColors.accentColor(widget.isDark),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 👤 Avatar Image Widget
// ═══════════════════════════════════════════════════════════════════════════
class AppAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Color? backgroundColor;
  final Color? textColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final double? fontSize;

  const AppAvatarImage({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 50,
    this.borderRadius,
    this.isCircle = true,
    this.backgroundColor,
    this.textColor,
    this.border,
    this.boxShadow,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (hasImage
                ? ImageColors.background(isDark)
                : ImageColors.accentColor(isDark)),
        borderRadius: isCircle
            ? BorderRadius.circular(size / 2)
            : (borderRadius ?? BorderRadius.circular(12)),
        border: border ??
            Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : ImageColors.accentColor(isDark).withOpacity(0.2),
              width: 2,
            ),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: ImageColors.accentColor(isDark).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(size / 2)
            : (borderRadius ?? BorderRadius.circular(12)),
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitials(isDark),
                errorWidget: (context, url, error) => _buildInitials(isDark),
              )
            : _buildInitials(isDark),
      ),
    );
  }

  Widget _buildInitials(bool isDark) {
    final initials = _getInitials(name ?? 'U');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ImageColors.accentColor(isDark),
            ImageColors.accentColor(isDark).withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize ?? (size * 0.4),
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Legacy Function Wrappers (للتوافقية مع الكود القديم)
// ═══════════════════════════════════════════════════════════════════════════

/// Legacy wrapper for network image loading
Widget loadingImage({
  required String image,
  double? width,
  double? height,
  BorderRadius? borderRadius,
  BoxFit? boxFit,
}) {
  return AppNetworkImage(
    imageUrl: image,
    width: width,
    height: height,
    borderRadius: borderRadius,
    fit: boxFit ?? BoxFit.cover,
  );
}

/// Legacy wrapper for file image loading
Widget loadingAssetsImage({
  required String image,
  required double width,
  required double height,
  BorderRadius? borderRadius,
}) {
  return AppFileImage(
    filePath: image,
    width: width,
    height: height,
    borderRadius: borderRadius,
  );
}
