import 'package:app/business_logic/OffersCubit/offers_cubit.dart';
import 'package:app/data/constants/api_constants.dart';
import 'package:app/functions/functions.dart';
import 'package:app/helpers/my_navigation.dart';
import 'package:app/models/offers/OffersModel.dart';
import 'package:app/persentation/screens/offers/offers_details.dart';
import 'package:app/persentation/screens/offers/offers_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ════════════════════════════════════════════════════════════════════════════
// 🎁 Offers Slider Section (Home Page)
// صورة العرض كخلفية للكرت مع التفاصيل فوقها
// ════════════════════════════════════════════════════════════════════════════
class OffersSliderSection extends StatelessWidget {
  const OffersSliderSection({super.key});

  static const Color _purple = Color(0xFF6842E2);
  static const Color _purpleLight = Color(0xFF9B5FF5);

  static String? resolveOfferImage(OfferData offer) {
    final full = offer.imageUrl?.trim();
    if (full != null && full.isNotEmpty) {
      if (full.startsWith('http://') || full.startsWith('https://')) {
        return full;
      }
      return '${ApiConstants.stoarge}${full.startsWith('/') ? full.substring(1) : full}';
    }

    final relative = offer.image?.trim();
    if (relative != null && relative.isNotEmpty) {
      if (relative.startsWith('http://') || relative.startsWith('https://')) {
        return relative;
      }
      return '${ApiConstants.stoarge}${relative.startsWith('/') ? relative.substring(1) : relative}';
    }
    return null;
  }

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        final cubit = OffersCubit.get(context);
        final offers = cubit.offersList;
        final isDark = _isDark(context);

        if (state is OffersLoading && offers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: _OffersShimmer(),
          );
        }

        if (offers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _PromoFallbackCard(
              isDark: isDark,
              onTap: () =>
                  MyNavigator.navigateTo(context, const OffersScreen()),
            ),
          );
        }

        // كرت عريض بصورة العرض كخلفية والتفاصيل فوقها
        final screenW = MediaQuery.of(context).size.width;
        const horizontalPadding = 16.0;
        const gap = 12.0;
        final cardWidth = (screenW - horizontalPadding * 2) * 0.82;
        final cardHeight = cardWidth * 0.62;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, offers.length, isDark),
              SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: gap),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _OfferSlideCard(
                      offer: offer,
                      imageUrl: resolveOfferImage(offer),
                      isDark: isDark,
                      width: cardWidth,
                      height: cardHeight,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        MyNavigator.navigateTo(
                          context,
                          OffersDetailsScreen(offerData: offer),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, _purpleLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _purple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.local_offer_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'offers_title'.tr(),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1D1D25),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: isDark ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _purple,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              MyNavigator.navigateTo(context, const OffersScreen());
            },
            child: Row(
              children: [
                Text(
                  'view_offers'.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _purple,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded,
                    color: _purple, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 🎴 Compact professional offer card
// ════════════════════════════════════════════════════════════════════════════
class _OfferSlideCard extends StatelessWidget {
  final OfferData offer;
  final String? imageUrl;
  final bool isDark;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _OfferSlideCard({
    required this.offer,
    required this.imageUrl,
    required this.isDark,
    required this.width,
    required this.height,
    required this.onTap,
  });

  static const Color _green = Color(0xFF28E6C5);

  bool get _isExpired => offer.isExpired == true;
  bool get _isUsed => offer.isUsed == true;
  bool get _isActive => offer.status == 'Active' && !_isExpired;

  int get _productsCount =>
      offer.productsCount ?? offer.products?.length ?? 0;

  Color get _statusColor {
    if (_isExpired || offer.status == 'Inactive') return const Color(0xFFFF4757);
    if (_isUsed) return const Color(0xFFD7B21B);
    return _green;
  }

  String get _statusLabel {
    if (_isExpired) return 'Expired'.tr();
    if (_isUsed) return 'Used'.tr();
    return _isActive ? 'Active'.tr() : 'Inactive'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _CardGradientBg(),
                    errorWidget: (_, __, ___) => const _GradientPlaceholder(),
                  )
                : const _GradientPlaceholder(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0xCC0B0718),
                  ],
                  stops: [0, 0.38, 1],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    offer.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_productsCount ${'products'.tr()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPrice(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    final price = offer.special_price_after_tax ?? offer.specialPrice;
    if (price == null) {
      if (offer.expiryDate == null || offer.expiryDate!.isEmpty) {
        return const SizedBox.shrink();
      }
      String dateText = offer.expiryDate!;
      try {
        dateText = formatDate(context, DateTime.parse(offer.expiryDate!));
      } catch (_) {}
      return Row(
        children: [
          const Icon(Icons.event_rounded, size: 13, color: Colors.white70),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              dateText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '$price',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(width: 4),
          context.getCurrencyWidget(height: 12, color: Colors.white),
        ],
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB07CFF),
            Color(0xFF7A4AE8),
            Color(0xFF5B2FD6),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _CardGradientBg extends StatelessWidget {
  const _CardGradientBg();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B5CFF), Color(0xFF6D3DF5)],
        ),
      ),
    );
  }
}

class _OffersShimmer extends StatelessWidget {
  const _OffersShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.withValues(alpha: 0.15);

    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = (screenW - 32) * 0.82;
    final cardHeight = cardWidth * 0.62;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Container(
            width: 140,
            height: 20,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoFallbackCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _PromoFallbackCard({required this.isDark, required this.onTap});

  static const Color _purple = Color(0xFF6842E2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF9B5CFF), Color(0xFF6D3DF5), Color(0xFF4B22D6)],
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'offers_title'.tr(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'offers_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
