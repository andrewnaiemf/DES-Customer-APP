import 'package:flutter/material.dart';
import 'responsive_utils.dart';
import 'responsive_config.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📱 RESPONSIVE BUILDER
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType, Orientation) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final deviceType = ResponsiveUtils.getDeviceType(context);
        return builder(context, deviceType, orientation);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 RESPONSIVE LAYOUT BUILDER
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? mobileLarge;
  final Widget? tablet;
  final Widget? tabletLarge;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.mobileLarge,
    this.tablet,
    this.tabletLarge,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, orientation) {
        switch (deviceType) {
          case DeviceType.mobileSmall:
          case DeviceType.mobileMedium:
            return mobile;
          case DeviceType.mobileLarge:
          case DeviceType.mobileXLarge:
            return mobileLarge ?? mobile;
          case DeviceType.tabletSmall:
          case DeviceType.tabletMedium:
            return tablet ?? mobileLarge ?? mobile;
          case DeviceType.tabletLarge:
          case DeviceType.tabletXLarge:
            return tabletLarge ?? tablet ?? mobileLarge ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tabletLarge ?? tablet ?? mobileLarge ?? mobile;
        }
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 RESPONSIVE CONTAINER
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  final bool centerOnLargeScreens;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.constraints,
    this.centerOnLargeScreens = true,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width != null ? ResponsiveUtils.width(context, width!) : null,
      height: height != null ? ResponsiveUtils.height(context, height!) : null,
      padding: _getResponsivePadding(context),
      margin: _getResponsiveMargin(context),
      decoration: decoration,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );

    // Apply max width constraint for large screens
    if (centerOnLargeScreens && (context.isTablet || context.isDesktop)) {
      final effectiveMaxWidth = maxWidth ?? ResponsiveUtils.maxContentWidth(context);
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: content,
        ),
      );
    }

    return content;
  }

  EdgeInsetsGeometry? _getResponsivePadding(BuildContext context) {
    if (padding == null) return null;
    if (padding is EdgeInsets) {
      final p = padding as EdgeInsets;
      return EdgeInsets.only(
        left: ResponsiveUtils.spacing(context, p.left),
        right: ResponsiveUtils.spacing(context, p.right),
        top: ResponsiveUtils.spacing(context, p.top),
        bottom: ResponsiveUtils.spacing(context, p.bottom),
      );
    }
    return padding;
  }

  EdgeInsetsGeometry? _getResponsiveMargin(BuildContext context) {
    if (margin == null) return null;
    if (margin is EdgeInsets) {
      final m = margin as EdgeInsets;
      return EdgeInsets.only(
        left: ResponsiveUtils.spacing(context, m.left),
        right: ResponsiveUtils.spacing(context, m.right),
        top: ResponsiveUtils.spacing(context, m.top),
        bottom: ResponsiveUtils.spacing(context, m.bottom),
      );
    }
    return margin;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📝 RESPONSIVE TEXT
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? decoration;
  final TextStyle? style;

  const ResponsiveText(
      this.text, {
        super.key,
        required this.fontSize,
        this.fontWeight,
        this.color,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.height,
        this.letterSpacing,
        this.decoration,
        this.style,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: ResponsiveUtils.font(context, fontSize),
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 RESPONSIVE ICON
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const ResponsiveIcon(
      this.icon, {
        super.key,
        required this.size,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: ResponsiveUtils.icon(context, size),
      color: color,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📏 RESPONSIVE SIZED BOX
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  const ResponsiveSizedBox.width(double width, {super.key, this.child})
      : width = width,
        height = null;

  const ResponsiveSizedBox.height(double height, {super.key, this.child})
      : height = height,
        width = null;

  const ResponsiveSizedBox.square(double size, {super.key, this.child})
      : width = size,
        height = size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width != null ? ResponsiveUtils.spacing(context, width!) : null,
      height: height != null ? ResponsiveUtils.spacing(context, height!) : null,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 RESPONSIVE BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final bool expand;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 48,
    this.fontSize = 15,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.buttonHeight(context, height);

    Widget button = SizedBox(
      width: expand ? double.infinity : (width != null ? ResponsiveUtils.width(context, width!) : null),
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding ?? ResponsiveUtils.paddingSymmetric(context, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: ResponsiveUtils.borderRadius(context, borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: ResponsiveUtils.icon(context, 20),
          height: ResponsiveUtils.icon(context, 20),
          child: CircularProgressIndicator(
            color: textColor ?? Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              ResponsiveSizedBox.width(8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.font(context, fontSize),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return button;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 RESPONSIVE CARD
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final double? elevation;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 16,
    this.elevation,
    this.border,
    this.gradient,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      width: width != null ? ResponsiveUtils.width(context, width!) : null,
      height: height != null ? ResponsiveUtils.height(context, height!) : null,
      margin: _getResponsiveMargin(context),
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: ResponsiveUtils.borderRadius(context, borderRadius),
        border: border,
        boxShadow: boxShadow ?? (elevation != null
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation!,
            offset: Offset(0, elevation! / 2),
          ),
        ]
            : null),
      ),
      child: ClipRRect(
        borderRadius: ResponsiveUtils.borderRadius(context, borderRadius),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: _getResponsivePadding(context),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }

  EdgeInsetsGeometry _getResponsivePadding(BuildContext context) {
    if (padding != null) {
      if (padding is EdgeInsets) {
        final p = padding as EdgeInsets;
        return EdgeInsets.only(
          left: ResponsiveUtils.spacing(context, p.left),
          right: ResponsiveUtils.spacing(context, p.right),
          top: ResponsiveUtils.spacing(context, p.top),
          bottom: ResponsiveUtils.spacing(context, p.bottom),
        );
      }
      return padding!;
    }
    return ResponsiveUtils.cardPadding(context);
  }

  EdgeInsetsGeometry? _getResponsiveMargin(BuildContext context) {
    if (margin == null) return null;
    if (margin is EdgeInsets) {
      final m = margin as EdgeInsets;
      return EdgeInsets.only(
        left: ResponsiveUtils.spacing(context, m.left),
        right: ResponsiveUtils.spacing(context, m.right),
        top: ResponsiveUtils.spacing(context, m.top),
        bottom: ResponsiveUtils.spacing(context, m.bottom),
      );
    }
    return margin;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📊 RESPONSIVE GRID
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  final int? crossAxisCount;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio,
    this.crossAxisCount,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = crossAxisCount ?? ResponsiveUtils.gridColumns(context);
    final aspectRatio = childAspectRatio ?? ResponsiveUtils.gridAspectRatio(context);

    return GridView.builder(
      padding: padding ?? ResponsiveUtils.pagePadding(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: ResponsiveUtils.spacing(context, runSpacing),
        crossAxisSpacing: ResponsiveUtils.spacing(context, spacing),
        childAspectRatio: aspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📏 RESPONSIVE PADDING
// ═══════════════════════════════════════════════════════════════════════════

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.padding,
  });

  factory ResponsivePadding.all(double value, {required Widget child}) {
    return ResponsivePadding(
      padding: EdgeInsets.all(value),
      child: child,
    );
  }

  factory ResponsivePadding.symmetric({
    double horizontal = 0,
    double vertical = 0,
    required Widget child,
  }) {
    return ResponsivePadding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry responsivePadding = padding;

    if (padding is EdgeInsets) {
      final p = padding as EdgeInsets;
      responsivePadding = EdgeInsets.only(
        left: ResponsiveUtils.spacing(context, p.left),
        right: ResponsiveUtils.spacing(context, p.right),
        top: ResponsiveUtils.spacing(context, p.top),
        bottom: ResponsiveUtils.spacing(context, p.bottom),
      );
    }

    return Padding(
      padding: responsivePadding,
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖼️ RESPONSIVE IMAGE
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const ResponsiveImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: ResponsiveUtils.borderRadius(context, borderRadius),
      child: Image(
        image: image,
        width: width != null ? ResponsiveUtils.width(context, width!) : null,
        height: height != null ? ResponsiveUtils.height(context, height!) : null,
        fit: fit,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔲 RESPONSIVE DIVIDER
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  const ResponsiveDivider({
    super.key,
    this.height = 16,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: ResponsiveUtils.spacing(context, height),
      thickness: thickness,
      indent: ResponsiveUtils.spacing(context, indent),
      endIndent: ResponsiveUtils.spacing(context, endIndent),
      color: color,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 RESPONSIVE SCAFFOLD
// ═══════════════════════════════════════════════════════════════════════════

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool centerContent;
  final double? maxContentWidth;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.centerContent = true,
    this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    // Center content on large screens
    if (centerContent && (context.isTablet || context.isDesktop)) {
      final effectiveMaxWidth = maxContentWidth ?? ResponsiveUtils.maxContentWidth(context);
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: body,
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}