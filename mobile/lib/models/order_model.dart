import 'user_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final int tukangId;
  final String description;
  final String? imagePath;
  final String status;
  final int? totalPrice;
  final String createdAt;
  final UserModel? user;
  final UserModel? tukang;
  final dynamic review;

  OrderModel({
    required this.id,
    required this.userId,
    required this.tukangId,
    required this.description,
    this.imagePath,
    required this.status,
    this.totalPrice,
    required this.createdAt,
    this.user,
    this.tukang,
    this.review,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      tukangId: json['tukang_id'] is int ? json['tukang_id'] : int.tryParse(json['tukang_id']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      imagePath: json['image_path']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      totalPrice: json['total_price'] != null ? int.tryParse(json['total_price'].toString()) : null,
      createdAt: json['created_at']?.toString() ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      tukang: json['tukang'] != null ? UserModel.fromJson(json['tukang']) : null,
      review: json['review'],
    );
  }
}
