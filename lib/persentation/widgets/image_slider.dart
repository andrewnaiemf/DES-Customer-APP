import 'package:app/persentation/widgets/photo_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/constants/api_constants.dart';

// ==================== App Theme Colors ====================
class AppTheme {
  static const Color yellow = Color.fromRGBO(217, 179, 29, 1.0);
  static const Color black = Color(0xFF1D1D25);
  static const Color background = Color(0xFF15172A);
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color red = Color(0xFFFF4757);
}

class ImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final double? height;
  final double borderRadius;
  final bool showCounter;
  final bool enableZoom;
  final bool autoPlay;
  final Duration autoPlayDuration;

  const ImageSlider({
    super.key,
    required this.images,
    this.height,
    this.borderRadius = 24,
    this.showCounter = true,
    this.enableZoom = true,
    this.autoPlay = false,
    this.autoPlayDuration = const Duration(seconds: 4),
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Auto play functionality
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayDuration, () {
      if (mounted && widget.autoPlay) {
        int nextPage = (_currentPageNotifier.value + 1) % widget.images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        height: widget.height ?? MediaQuery.of(context).size.width * 0.55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withOpacity(0.4)
                  : AppTheme.purple.withOpacity(0.15),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image PageView
            _buildPageView(),
            // Gradient Overlay
            _buildGradientOverlay(),
            // Page Indicator
            _buildModernIndicator(),
            // Counter Badge
            if (widget.showCounter) _buildCounterBadge(),
            // Zoom Icon
            if (widget.enableZoom) _buildZoomIcon(),
          ],
        ),
      ),
    );
  }

  // ==================== Empty State ====================
  Widget _buildEmptyState() {
    return Container(
      height: widget.height ?? MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.dark, AppTheme.background]
              : [AppTheme.lightGray, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.darkGray.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _isDark
                  ? AppTheme.purple.withOpacity(0.2)
                  : AppTheme.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 40,
              color: _isDark ? AppTheme.lightGreen : AppTheme.purple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Images Available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isDark ? AppTheme.darkGray : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Page View ====================
  Widget _buildPageView() {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _onImageTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            HapticFeedback.selectionClick();
            _currentPageNotifier.value = index;
          },
          itemBuilder: (context, index) {
            return _buildImageItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    String imageUrl = ApiConstants.stoarge + widget.images[index];

    return Hero(
      tag: 'image_$index',
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.dark, AppTheme.background]
              : [AppTheme.lightGray, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: _AnimatedLoadingIndicator(isDark: _isDark),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDark
              ? [AppTheme.dark, AppTheme.background]
              : [AppTheme.lightGray, Colors.white],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.red.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.broken_image_rounded,
              size: 32,
              color: AppTheme.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load image',
            style: TextStyle(
              fontSize: 12,
              color: _isDark ? AppTheme.darkGray : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Gradient Overlay ====================
  Widget _buildGradientOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 80,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(widget.borderRadius),
          ),
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // ==================== Modern Indicator ====================
  Widget _buildModernIndicator() {
    if (widget.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPageNotifier,
        builder: (context, currentPage, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              return _buildIndicatorDot(index, currentPage);
            }),
          );
        },
      ),
    );
  }

  Widget _buildIndicatorDot(int index, int currentPage) {
    bool isActive = index == currentPage;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 28 : 10,
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: isActive
              ? LinearGradient(
            colors: [
              AppTheme.lightGreen,
              AppTheme.lightGreen.withOpacity(0.8),
            ],
          )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.4),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: AppTheme.lightGreen.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
      ),
    );
  }

  // ==================== Counter Badge ====================
  Widget _buildCounterBadge() {
    if (widget.images.length <= 1) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: ValueListenableBuilder<int>(
        valueListenable: _currentPageNotifier,
        builder: (context, currentPage, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_library_rounded,
                  color: AppTheme.lightGreen,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${currentPage + 1}/${widget.images.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== Zoom Icon ====================
  Widget _buildZoomIcon() {
    return Positioned(
      top: 16,
      left: 16,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onImageTap();
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Icon(
            Icons.zoom_in_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ==================== Image Tap Handler ====================
  void _onImageTap() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PhotoViewer(
            image: ApiConstants.stoarge +
                widget.images[_currentPageNotifier.value],
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// ==================== Animated Loading Indicator ====================
class _AnimatedLoadingIndicator extends StatefulWidget {
  final bool isDark;

  const _AnimatedLoadingIndicator({required this.isDark});

  @override
  State<_AnimatedLoadingIndicator> createState() =>
      _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<_AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.purple.withOpacity(0.3),
                    AppTheme.lightGreen.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.image_rounded,
                size: 32,
                color: widget.isDark ? AppTheme.lightGreen : AppTheme.purple,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== Enhanced Image Slider with Thumbnails ====================
class ImageSliderWithThumbnails extends StatefulWidget {
  final List<dynamic> images;
  final double? height;
  final double thumbnailHeight;

  const ImageSliderWithThumbnails({
    super.key,
    required this.images,
    this.height,
    this.thumbnailHeight = 70,
  });

  @override
  State<ImageSliderWithThumbnails> createState() =>
      _ImageSliderWithThumbnailsState();
}

class _ImageSliderWithThumbnailsState extends State<ImageSliderWithThumbnails> {
  late PageController _pageController;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Main Image Slider
        ImageSlider(
          images: widget.images,
          height: widget.height,
          showCounter: false,
        ),
        const SizedBox(height: 16),
        // Thumbnails
        if (widget.images.length > 1) _buildThumbnailStrip(),
      ],
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: widget.thumbnailHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _buildThumbnailItem(index);
        },
      ),
    );
  }

  Widget _buildThumbnailItem(int index) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        bool isSelected = index == currentPage;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _currentPageNotifier.value = index;
            // Sync with main slider if needed
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.only(right: 12),
            width: widget.thumbnailHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightGreen
                    : (_isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppTheme.darkGray.withOpacity(0.3)),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppTheme.lightGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: ApiConstants.stoarge + widget.images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: _isDark
                          ? AppTheme.dark
                          : AppTheme.lightGray,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: _isDark
                          ? AppTheme.dark
                          : AppTheme.lightGray,
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppTheme.darkGray,
                        size: 20,
                      ),
                    ),
                  ),
                  // Selection Overlay
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightGreen.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== Full Screen Image Slider ====================
class FullScreenImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullScreenImageSlider({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageSlider> createState() => _FullScreenImageSliderState();
}

class _FullScreenImageSliderState extends State<FullScreenImageSlider>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late ValueNotifier<int> _currentPageNotifier;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPageNotifier = ValueNotifier<int>(widget.initialIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Image PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                _currentPageNotifier.value = index;
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.stoarge + widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightGreen,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.broken_image_rounded,
                        color: AppTheme.darkGray,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Close Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            // Counter
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, currentPage, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '${currentPage + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Indicator
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 30,
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, currentPage, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (index) {
                      bool isActive = index == currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppTheme.lightGreen
                              : Colors.white.withOpacity(0.4),
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color:
                              AppTheme.lightGreen.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                              : null,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}