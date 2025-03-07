import 'package:get/get.dart';

class BookingPriceItem {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? createdAt;

  BookingPriceItem({
    this.id,
    this.title,
    this.description,
    this.createdAt,
  });

  factory BookingPriceItem.fromJson(Map<String, dynamic> json) {
    return BookingPriceItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class BookingPriceController extends GetxController {}
