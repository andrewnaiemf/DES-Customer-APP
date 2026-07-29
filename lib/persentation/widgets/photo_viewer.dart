import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Photo Viewer Colors
// ═══════════════════════════════════════════════════════════════════════════
class PhotoViewerColors {
  // Light Mode
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightIcon = Color(0xFF6B7280);

  // Dark Mode
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkText = Colors.white;
  static const Color darkIcon = Color(0xFF9CA3AF);

  // Accent Colors
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color red = Color(0xFFEF4444);

  // Helpers
  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static Color text(bool isDark) => isDark ? darkText : lightText;

  static Color icon(bool isDark) => isDark ? darkIcon : lightIcon;

  static Color accent(bool isDark) => isDark ? lightGreen : purple;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖼️ Single Photo Viewer
// ═══════════════════════════════════════════════════════════════════════════
class PhotoViewer extends StatefulWidget {
  final String image;
  final String? heroTag;
  final String? title;
  final bool isFile;
  final bool showAppBar;
  final bool enableRotation;
  final double minScale;
  final double maxScale;
  final Color? backgroundColor;

  const PhotoViewer({
    super.key,
    required this.image,
    this.heroTag,
    this.title,
    this.isFile = false,
    this.showAppBar = true,
    this.enableRotation = true,
    this.minScale = 0.5,
    this.maxScale = 4.0,
    this.backgroundColor,
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isAppBarVisible = true;
  bool _isLoading = true;
  bool _hasError = false;
  double _currentScale = 1.0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Set system UI overlay style
    _updateSystemUI();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Reset system UI
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
    ));
    super.dispose();
  }

  void _toggleAppBar() {
    HapticFeedback.lightImpact();
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
    if (_isAppBarVisible) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  ImageProvider _getImageProvider() {
    if (widget.isFile) {
      return FileImage(File(widget.image));
    }
    return CachedNetworkImageProvider(widget.image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      widget.backgroundColor ?? PhotoViewerColors.background(_isDark),
      body: Stack(
        children: [
          // Photo View
          GestureDetector(
            onTap: _toggleAppBar,
            child: _buildPhotoView(),
          ),

          // App Bar
          if (widget.showAppBar) _buildAnimatedAppBar(),

          // Loading Indicator
          if (_isLoading) _buildLoadingIndicator(),

          // Error Widget
          if (_hasError) _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildPhotoView() {
    final imageProvider = _getImageProvider();

    return Hero(
      tag: widget.heroTag ?? widget.image,
      child: PhotoView(
        imageProvider: imageProvider,
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(
          color:
          widget.backgroundColor ?? PhotoViewerColors.background(_isDark),
        ),
        enableRotation: widget.enableRotation,
        loadingBuilder: (context, event) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isLoading) {
              setState(() => _isLoading = true);
            }
          });
          return const SizedBox.shrink();
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          });
          return const SizedBox.shrink();
        },
        scaleStateChangedCallback: (scaleState) {
          // Handle scale state changes
        },
        onScaleEnd: (context, details, controllerValue) {
          setState(() {
            _currentScale = controllerValue.scale ?? 1.0;
          });
        },
        onTapUp: (context, details, controllerValue) {
          _toggleAppBar();
        },
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: _isAppBarVisible ? 0 : -120,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Back Button
                _buildControlButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                // Title
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }  Widget _buildBottomControls() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: _isAppBarVisible ? 0 : -100,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () => _shareImage(),
                ),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Save',
                  onTap: () => _saveImage(),
                ),
                _buildActionButton(
                  icon: Icons.zoom_in_rounded,
                  label: '${(_currentScale * 100).toInt()}%',
                  onTap: () {},
                  isHighlighted: true,
                ),
                _buildActionButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Info',
                  onTap: () => _showImageInfo(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? PhotoViewerColors.accent(_isDark).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHighlighted
                    ? PhotoViewerColors.accent(_isDark).withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              color: isHighlighted
                  ? PhotoViewerColors.accent(_isDark)
                  : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PhotoViewerColors.accent(_isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: PhotoViewerColors.surface(_isDark),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PhotoViewerColors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.broken_image_rounded,
                size: 48,
                color: PhotoViewerColors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PhotoViewerColors.text(_isDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The image could not be loaded.\nPlease check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: PhotoViewerColors.icon(_isDark),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildErrorButton(
                  icon: Icons.refresh_rounded,
                  label: 'Retry',
                  isPrimary: true,
                  onTap: () {
                    setState(() {
                      _hasError = false;
                      _isLoading = true;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildErrorButton(
                  icon: Icons.close_rounded,
                  label: 'Close',
                  isPrimary: false,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
            colors: [
              PhotoViewerColors.accent(_isDark),
              PhotoViewerColors.accent(_isDark).withOpacity(0.8),
            ],
          )
              : null,
          color: isPrimary ? null : PhotoViewerColors.icon(_isDark).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : PhotoViewerColors.icon(_isDark),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : PhotoViewerColors.icon(_isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _OptionsBottomSheet(
        isDark: _isDark,
        onShare: _shareImage,
        onSave: _saveImage,
        onCopy: _copyImage,
      ),
    );
  }

  void _shareImage() {
    // Implement share functionality
    HapticFeedback.mediumImpact();
    // Share.share(widget.image);
  }

  void _saveImage() {
    // Implement save functionality
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image saved to gallery'),
        backgroundColor: PhotoViewerColors.accent(_isDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyImage() {
    // Implement copy functionality
    HapticFeedback.mediumImpact();
  }

  void _showImageInfo() {
    // Show image info
    HapticFeedback.lightImpact();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖼️ Photo Gallery Viewer (Multiple Images)
// ═══════════════════════════════════════════════════════════════════════════
class PhotoGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTagPrefix;
  final bool isFile;
  final bool showIndicator;

  const PhotoGalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTagPrefix,
    this.isFile = false,
    this.showIndicator = true,
  });

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isAppBarVisible = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    HapticFeedback.lightImpact();
    setState(() => _isAppBarVisible = !_isAppBarVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PhotoViewerColors.background(_isDark),
      body: Stack(
        children: [
          // Photo Gallery
          GestureDetector(
            onTap: _toggleAppBar,
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.images.length,
              builder: (context, index) {
                final image = widget.images[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: widget.isFile
                      ? FileImage(File(image)) as ImageProvider
                      : CachedNetworkImageProvider(image) as ImageProvider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  heroAttributes: widget.heroTagPrefix != null
                      ? PhotoViewHeroAttributes(
                    tag: '${widget.heroTagPrefix}_$index',
                  )
                      : null,
                );
              },
              backgroundDecoration: BoxDecoration(
                color: PhotoViewerColors.background(_isDark),
              ),
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PhotoViewerColors.accent(_isDark),
                  ),
                ),
              ),
            ),
          ),

          // App Bar
          _buildAppBar(),

          // Bottom Indicator
          if (widget.showIndicator && widget.images.length > 1)
            _buildBottomIndicator(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: _isAppBarVisible ? 0 : -120,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                // Counter
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: _isAppBarVisible ? 40 : -60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.images.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? PhotoViewerColors.accent(_isDark)
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
              boxShadow: _currentIndex == index
                  ? [
                BoxShadow(
                  color: PhotoViewerColors.accent(_isDark).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📋 Options Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════
class _OptionsBottomSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onCopy;

  const _OptionsBottomSheet({
    required this.isDark,
    required this.onShare,
    required this.onSave,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PhotoViewerColors.surface(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: PhotoViewerColors.icon(isDark).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: PhotoViewerColors.text(isDark),
            ),
          ),
          const SizedBox(height: 16),
          // Options
          _buildOption(
            context,
            icon: Icons.share_rounded,
            label: 'Share Image',
            onTap: () {
              Navigator.pop(context);
              onShare();
            },
          ),
          _buildOption(
            context,
            icon: Icons.download_rounded,
            label: 'Save to Gallery',
            onTap: () {
              Navigator.pop(context);
              onSave();
            },
          ),
          _buildOption(
            context,
            icon: Icons.copy_rounded,
            label: 'Copy Image',
            onTap: () {
              Navigator.pop(context);
              onCopy();
            },
          ),
          _buildOption(
            context,
            icon: Icons.open_in_browser_rounded,
            label: 'Open in Browser',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          // Cancel Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: PhotoViewerColors.icon(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PhotoViewerColors.text(isDark),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PhotoViewerColors.accent(isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: PhotoViewerColors.accent(isDark),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: PhotoViewerColors.text(isDark),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: PhotoViewerColors.icon(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🚀 Helper Functions for Easy Navigation
// ═══════════════════════════════════════════════════════════════════════════

/// Open single photo viewer
void openPhotoViewer(
    BuildContext context, {
      required String image,
      String? heroTag,
      String? title,
      bool isFile = false,
    }) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => PhotoViewer(
        image: image,
        heroTag: heroTag,
        title: title,
        isFile: isFile,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}

/// Open photo gallery viewer
void openPhotoGallery(
    BuildContext context, {
      required List<String> images,
      int initialIndex = 0,
      String? heroTagPrefix,
      bool isFile = false,
    }) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          PhotoGalleryViewer(
            images: images,
            initialIndex: initialIndex,
            heroTagPrefix: heroTagPrefix,
            isFile: isFile,
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}