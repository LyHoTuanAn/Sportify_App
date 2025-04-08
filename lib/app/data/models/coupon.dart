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
    // Parse id to int
    int idValue = 0;
    if (map['id'] != null) {
      if (map['id'] is String) {
        idValue = int.tryParse(map['id']) ?? 0;
      } else {
        idValue = map['id'];
      }
    }

    // Parse amount to int
    int amountValue = 0;
    if (map['amount'] != null) {
      if (map['amount'] is String) {
        // Handle decimal point in amount string (e.g. "123.00")
        final amountStr = map['amount'].toString().split('.').first;
        amountValue = int.tryParse(amountStr) ?? 0;
      } else {
        amountValue = map['amount'];
      }
    }

    // Parse create_user to int
    int createUserValue = 0;
    if (map['create_user'] != null) {
      if (map['create_user'] is String) {
        createUserValue = int.tryParse(map['create_user']) ?? 0;
      } else {
        createUserValue = map['create_user'];
      }
    }

    return Coupon(
      id: idValue,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      amount: amountValue,
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
      createUser: createUserValue,
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
