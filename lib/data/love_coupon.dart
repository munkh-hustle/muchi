// lib\data\love_coupon.dart
class LoveCoupon {
  final String id;
  final String title;
  final String description;
  final DateTime expirationDate;
  final bool isRedeemed;
  final DateTime createdAt;

  LoveCoupon({
    required this.id,
    required this.title,
    required this.description,
    required this.expirationDate,
    this.isRedeemed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // For JSON serialization
  factory LoveCoupon.fromJson(Map<String, dynamic> json) {
    return LoveCoupon(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      expirationDate: DateTime.parse(json['expirationDate']),
      isRedeemed: json['isRedeemed'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'expirationDate': expirationDate.toIso8601String(),
      'isRedeemed': isRedeemed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}