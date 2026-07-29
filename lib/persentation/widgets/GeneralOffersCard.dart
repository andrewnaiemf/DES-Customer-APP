import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/constants/assets.dart';

class GeneralOffersCard extends StatefulWidget {
  final int offersCount;
  final VoidCallback onTap;
  final bool isDark;
  final String? productImagePath;

  const GeneralOffersCard({
    super.key,
    required this.offersCount,
    required this.onTap,
    this.isDark = false,
    this.productImagePath,
  });

  @override
  State<GeneralOffersCard> createState() => _GeneralOffersCardState();
}

class _GeneralOffersCardState extends State<GeneralOffersCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color primaryPurple = Color(0xFF6B35E8);
  static const Color lightPurple = Color(0xFF9B5FF5);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = 24.0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              children: [
                // glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withValues(
                            alpha: 0.5 * _pulseAnimation.value,
                          ),
                          blurRadius: 35,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),

                // CARD
                ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFC58CFF),
                          Color(0xFF9B5CFF),
                          Color(0xFF6D3DF5),
                          Color(0xFF4B22D6),
                        ],
                        stops: [0.0, 0.35, 0.7, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        ..._buildDecorations(),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildTopBadge(),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(child: _buildRightContent()),
                                  _buildLeftProductArea(),
                                ],
                              ),

                              const SizedBox(height: 10),

                              _buildFeatureChips(),

                              const SizedBox(height: 10),

                              _buildButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────── TOP BADGE ─────────
  Widget _buildTopBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer_outlined,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),

            Text(
              "Offers",
              // tr('offers_badge'),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),

            const SizedBox(width: 6),

            Text(
              '${widget.offersCount}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── RIGHT CONTENT ─────────
  Widget _buildRightContent() {
    final chips = [
      (Icons.workspace_premium_rounded, tr('feature_exclusive')),
      (Icons.credit_card_rounded, tr('feature_payment')),
      (Icons.assignment_outlined, tr('feature_terms')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('✦',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
            const SizedBox(width: 3),

            Text(
              tr('offers_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            tr('offers_subtitle'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),

        const SizedBox(height: 8),

        ...chips.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: _buildFeatureItem(c.$1, c.$2),
        )),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.white)),
      ],
    );
  }

  // ───────── LEFT IMAGE ─────────
  Widget _buildLeftProductArea() {
    return SizedBox(
      height: 150,
      width: 160,
      child: Image.asset(
        Assets.offerbox,
        fit: BoxFit.fill,
      ),
    );
  }

  // ───────── FEATURE CHIPS ─────────
  Widget _buildFeatureChips() {
    final chips = [
      (Icons.headset_mic_outlined, tr('chip_support')),
      (Icons.verified_user, tr('chip_warranty')),
      (Icons.verified_outlined, tr('chip_quality')),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.$1, color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text(c.$2, style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  // ───────── BUTTON ─────────
  Widget _buildButton() {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 20),
          Text(
            tr('view_offers'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: primaryPurple,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.chevron_right_rounded,
                color: primaryPurple, size: 22),
          ),
        ],
      ),
    );
  }

  // ───────── DECORATIONS ─────────
  List<Widget> _buildDecorations() {
    return [
      Positioned(
        top: -50,
        left: -40,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ),
      Positioned(
        bottom: -60,
        right: -30,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
    ];
  }
}