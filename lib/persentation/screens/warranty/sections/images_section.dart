import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/persentation/screens/warranty/warranty_strings.dart';
import 'package:app/persentation/screens/warranty/widgets/warranty_exports.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 📷 Premium Images Upload Section
// ═══════════════════════════════════════════════════════════════════════════
class ImagesSection extends StatefulWidget {
  final List<File> images;
  final Function(File) onImageAdded;
  final Function(int) onImageRemoved;
  final bool isDark;

  const ImagesSection({
    super.key,
    required this.images,
    required this.onImageAdded,
    required this.onImageRemoved,
    this.isDark = false,
  });

  @override
  State<ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends State<ImagesSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _selectedImageIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernSectionCard(
      title: 'Vehicle Photos',
      icon: Icons.photo_library_rounded,
      iconColor: AppTheme.pink,
      isDark: widget.isDark,
      children: [
        // ═══════════════════════════════════════════════════════════════
        // 📊 Progress Indicator
        // ═══════════════════════════════════════════════════════════════
        _buildProgressIndicator(),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════════════
        // ℹ️ Info Banner
        // ═══════════════════════════════════════════════════════════════
        _buildInfoBanner(),
        const SizedBox(height: 20),

        // ═══════════════════════════════════════════════════════════════
        // ➕ Add Image Button
        // ═══════════════════════════════════════════════════════════════
        _buildAddImageButton(context),

        // ═══════════════════════════════════════════════════════════════
        // 🖼️ Images Grid
        // ═══════════════════════════════════════════════════════════════
        if (widget.images.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildImagesGrid(context),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📊 Progress Indicator
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProgressIndicator() {
    final progress = widget.images.length / 5;
    final isComplete = widget.images.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(widget.isDark ? 0.15 : 0.08),
            (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(widget.isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle_rounded : Icons.photo_camera_rounded,
                      color: isComplete ? AppTheme.green : AppTheme.purple,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getText(widget.isDark),
                        ),
                      ),
                      Text(
                        isComplete ? 'Photos added successfully' : 'Add at least 1 photo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextSecondary(widget.isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${widget.images.length}/5',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isComplete ? AppTheme.green : AppTheme.purple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.getBorder(widget.isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 6,
                  width: MediaQuery.of(context).size.width * progress * 0.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isComplete
                          ? [AppTheme.green, AppTheme.lightGreen]
                          : [AppTheme.purple, AppTheme.purpleLight],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: (isComplete ? AppTheme.green : AppTheme.purple).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ℹ️ Info Banner
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.blue.withOpacity(widget.isDark ? 0.15 : 0.08),
            AppTheme.blue.withOpacity(widget.isDark ? 0.08 : 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(
          color: AppTheme.blue.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: AppTheme.blue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo Guidelines',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getText(widget.isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Clear photos of all protected areas • Max 5 photos • Required for warranty',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextSecondary(widget.isDark),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ➕ Add Image Button
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAddImageButton(BuildContext context) {
    final canAddMore = widget.images.length < 5;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: canAddMore && widget.images.isEmpty ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: PressableScale(
        onPressed: canAddMore ? () => _showImageSourcePicker(context) : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: canAddMore ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: canAddMore
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.purple.withOpacity(widget.isDark ? 0.15 : 0.1),
                  AppTheme.purpleLight.withOpacity(widget.isDark ? 0.1 : 0.05),
                ],
              )
                  : null,
              color: canAddMore ? null : AppTheme.getSurface(widget.isDark),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(
                color: canAddMore
                    ? AppTheme.purple.withOpacity(0.4)
                    : AppTheme.getBorder(widget.isDark),
                width: canAddMore ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: canAddMore ? AppTheme.primaryGradient() : null,
                    color: canAddMore ? null : AppTheme.getBorder(widget.isDark),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    boxShadow: canAddMore
                        ? [
                      BoxShadow(
                        color: AppTheme.purple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    canAddMore
                        ? Icons.add_photo_alternate_rounded
                        : Icons.block_rounded,
                    color: canAddMore ? Colors.white : AppTheme.getTextSecondary(widget.isDark),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canAddMore
                          ? 'Add Vehicle Photos'
                          : 'Maximum Reached',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: canAddMore
                            ? AppTheme.getText(widget.isDark)
                            : AppTheme.getTextSecondary(widget.isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          canAddMore ? Icons.camera_alt_rounded : Icons.check_circle_rounded,
                          size: 14,
                          color: canAddMore ? AppTheme.purple : AppTheme.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          canAddMore
                              ? 'Camera or Gallery • ${5 - widget.images.length} slots left'
                              : '5 photos uploaded',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getTextSecondary(widget.isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🖼️ Images Grid
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildImagesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.collections_rounded,
              size: 16,
              color: AppTheme.getTextSecondary(widget.isDark),
            ),
            const SizedBox(width: 8),
            Text(
              'Uploaded Photos',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextSecondary(widget.isDark),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: AppTheme.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.images.length} Added',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: _buildImageCard(context, index),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🖼️ Image Card
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildImageCard(BuildContext context, int index) {
    final isSelected = _selectedImageIndex == index;

    return GestureDetector(
      onTap: () => _viewImage(context, index),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => _selectedImageIndex = index);
        _showImageOptions(context, index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppTheme.purple
                : AppTheme.getBorder(widget.isDark),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.purple.withOpacity(0.3)
                  : Colors.black.withOpacity(widget.isDark ? 0.3 : 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Hero(
                tag: 'image_$index',
                child: Image.file(
                  widget.images[index],
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Remove Button
              Positioned(
                top: 6,
                right: 6,
                child: PressableScale(
                  scaleFactor: 0.85,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showRemoveConfirmation(context, index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.red,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.red.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),

              // Image Number Badge
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.purple.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              // Expand Icon
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📷 Show Image Source Picker
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> _showImageSourcePicker(BuildContext context) async {
    HapticFeedback.selectionClick();

    final remainingSlots = 5 - widget.images.length;
    if (remainingSlots <= 0) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PremiumImageSourcePicker(
        isDark: widget.isDark,
        remainingSlots: remainingSlots,
      ),
    );

    if (source == null) return;

    await _pickImage(source, remainingSlots);
  }

  Future<void> _pickImage(ImageSource source, int remainingSlots) async {
    try {
      final picker = ImagePicker();

      if (source == ImageSource.camera) {
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          HapticFeedback.mediumImpact();
          widget.onImageAdded(File(pickedFile.path));
        }
      } else {
        final pickedFiles = await picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFiles.isNotEmpty) {
          final imagesToAdd = pickedFiles.take(remainingSlots).toList();

          for (var pickedFile in imagesToAdd) {
            widget.onImageAdded(File(pickedFile.path));
          }

          HapticFeedback.mediumImpact();

          if (pickedFiles.length > remainingSlots && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Text('Only $remainingSlots images added (5 max)'),
                  ],
                ),
                backgroundColor: AppTheme.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔍 View Image Full Screen
  // ═══════════════════════════════════════════════════════════════════════
  void _viewImage(BuildContext context, int index) {
    HapticFeedback.selectionClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            images: widget.images,
            initialIndex: index,
            isDark: widget.isDark,
            onDelete: (idx) {
              Navigator.pop(context);
              _showRemoveConfirmation(context, idx);
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⚙️ Image Options
  // ═══════════════════════════════════════════════════════════════════════
  void _showImageOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCard(widget.isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.getBorder(widget.isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionItem(
              icon: Icons.fullscreen_rounded,
              title: 'View Full Screen',
              color: AppTheme.blue,
              onTap: () {
                Navigator.pop(context);
                _viewImage(context, index);
              },
            ),
            _buildOptionItem(
              icon: Icons.delete_rounded,
              title: 'Remove Photo',
              color: AppTheme.red,
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmation(context, index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).then((_) {
      setState(() => _selectedImageIndex = null);
    });
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.getSurface(widget.isDark),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.getText(widget.isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🗑️ Remove Confirmation
  // ═══════════════════════════════════════════════════════════════════════
  void _showRemoveConfirmation(BuildContext context, int index) async {
    final confirmed = await PremiumDialog.showConfirm(
      context: context,
      title: 'Remove Photo?',
      message: 'This photo will be removed from the warranty registration.',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      isDark: widget.isDark,
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      widget.onImageRemoved(index);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📸 Premium Image Source Picker
// ═══════════════════════════════════════════════════════════════════════════
class _PremiumImageSourcePicker extends StatelessWidget {
  final bool isDark;
  final int remainingSlots;

  const _PremiumImageSourcePicker({
    required this.isDark,
    required this.remainingSlots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDark),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),

          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getBorder(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getText(isDark),
                    ),
                  ),
                  Text(
                    '$remainingSlots slots available',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera',
                    subtitle: 'Take photo',
                    color: AppTheme.purple,
                    source: ImageSource.camera,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library_rounded,
                    title: 'Gallery',
                    subtitle: 'Choose photos',
                    color: AppTheme.blue,
                    source: ImageSource.gallery,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ImageSource source,
  }) {
    return PressableScale(
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context, source);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(isDark ? 0.15 : 0.1),
              color.withOpacity(isDark ? 0.08 : 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.getText(isDark),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🖼️ Full Screen Image Viewer
// ═══════════════════════════════════════════════════════════════════════════
class _FullScreenImageViewer extends StatefulWidget {
  final List<File> images;
  final int initialIndex;
  final bool isDark;
  final Function(int) onDelete;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
    required this.isDark,
    required this.onDelete,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'image_$index',
                    child: Image.file(widget.images[index]),
                  ),
                ),
              );
            },
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    PressableScale(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      ),
                    ),

                    // Page Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
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

                    // Delete Button
                    PressableScale(
                      onPressed: () => widget.onDelete(_currentIndex),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page Dots
          if (widget.images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.purple : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
