class Coupon {
  final int id;
  final String code;
  final String description;
  final double? discountAmount;
  final double? discountPercentage;
  final double? minOrderAmount;
  final DateTime? validFrom;
  final DateTime? validTo;
  final bool active;
  final int? usageLimit;
  final int usedCount;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    this.discountAmount,
    this.discountPercentage,
    this.minOrderAmount,
    this.validFrom,
    this.validTo,
    required this.active,
    this.usageLimit,
    required this.usedCount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountAmount: json['discountAmount']?.toDouble(),
      discountPercentage: json['discountPercentage']?.toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom']) : null,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo']) : null,
      active: json['active'],
      usageLimit: json['usageLimit'],
      usedCount: json['usedCount'] ?? 0,
    );
  }
}