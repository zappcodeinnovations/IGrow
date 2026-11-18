import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/app_config_service.dart';
import '../providers/discount_banner_provider.dart';
import 'offer_dialog.dart';

class FloatingOfferBadge extends ConsumerWidget {
  const FloatingOfferBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide promotional badge during iOS App Store review when coupons/external discounts are disabled
    final canShowCoupons = ref.watch(appConfigProvider).canShowCoupons;
    if (!canShowCoupons) {
      return const SizedBox.shrink();
    }

    final bannerAsync = ref.watch(discountBannerProvider);

    return bannerAsync.when(
      data: (banner) {
        if (banner == null || !banner.active) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 24,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => OfferDialog.show(context, banner),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF047857), // emerald-700
                      Color(0xFF064E3B), // forest-900
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF34D399).withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gift Icon with glowing dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 18,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF064E3B),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SPECIAL OFFER',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                        Text(
                          banner.couponCode ?? 'WINTER200',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
