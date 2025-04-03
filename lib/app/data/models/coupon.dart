class Coupon {
  final int id;
  final String code;
  final String name;
  final int amount;
  final String discountType;
  final String endDate;
  final dynamic minTotal;
  final dynamic maxTotal;
  final dynamic services;
  final dynamic onlyForUser;
  final String status;
  final dynamic quantityLimit;
  final dynamic limitPerUser;
  final dynamic imageId;
  final int createUser;
  final dynamic updateUser;
  final dynamic deletedAt;
  final String createdAt;
  final String updatedAt;
  final dynamic authorId;
  final dynamic isVendor;

  Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.amount,
    required this.discountType,
    required this.endDate,
    this.minTotal,
    this.maxTotal,
    this.services,
    this.onlyForUser,
    required this.status,
    this.quantityLimit,
    this.limitPerUser,
    this.imageId,
    required this.createUser,
    this.updateUser,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.authorId,
    this.isVendor,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'],
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      amount: map['amount'] ?? 0,
      discountType: map['discount_type'] ?? '',
      endDate: map['end_date'] ?? '',
      minTotal: map['min_total'],
      maxTotal: map['max_total'],
      services: map['services'],
      onlyForUser: map['only_for_user'],
      status: map['status'] ?? '',
      quantityLimit: map['quantity_limit'],
      limitPerUser: map['limit_per_user'],
      imageId: map['image_id'],
      createUser: map['create_user'] ?? 0,
      updateUser: map['update_user'],
      deletedAt: map['deleted_at'],
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      authorId: map['author_id'],
      isVendor: map['is_vendor'],
    );
  }

  String get formattedEndDate {
    if (endDate.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(endDate);
      return 'Hết hạn: ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Hết hạn: $endDate';
    }
  }

  String get displayAmount {
    return discountType == 'fixed' ? amount.toString() : '$amount%';
  }
}
