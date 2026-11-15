import 'package:flutter/foundation.dart';

class DiscountBannerModel {
  final String id;
  final String title;
  final String text;
  final String? couponCode;
  final String? imageUrl;
  final String? videoUrl;
  final String? ctaLink;
  final String? ctaText;
  final bool active;

  const DiscountBannerModel({
    required this.id,
    required this.title,
    required this.text,
    this.couponCode,
    this.imageUrl,
    this.videoUrl,
    this.ctaLink,
    this.ctaText,
    this.active = true,
  });

  factory DiscountBannerModel.fromJson(Map<String, dynamic> json) {
    return DiscountBannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? json['description']?.toString() ?? '',
      couponCode: json['coupon_code']?.toString() ?? json['couponCode']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      videoUrl: json['video_url']?.toString() ?? json['videoUrl']?.toString(),
      ctaLink: json['cta_link']?.toString() ?? json['ctaLink']?.toString(),
      ctaText: json['cta_text']?.toString() ?? json['ctaText']?.toString() ?? 'Claim Offer',
      active: json['active'] == true || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'coupon_code': couponCode,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'cta_link': ctaLink,
      'cta_text': ctaText,
      'active': active,
    };
  }
}
