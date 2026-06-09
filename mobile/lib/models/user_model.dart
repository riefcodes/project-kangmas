class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final TukangProfile? tukangProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.tukangProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      tukangProfile: json['tukang_profile'] != null
          ? TukangProfile.fromJson(json['tukang_profile'])
          : null,
    );
  }
}

class TukangProfile {
  final int id;
  final String category;
  final double latitude;
  final double longitude;
  final String address;
  final bool isActive;
  final double avgRating;
  final int totalReviews;
  final int basePrice;

  TukangProfile({
    required this.id,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isActive,
    required this.avgRating,
    required this.totalReviews,
    required this.basePrice,
  });

  factory TukangProfile.fromJson(Map<String, dynamic> json) {
    return TukangProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? '',
      latitude: json['latitude'] != null ? (num.tryParse(json['latitude'].toString())?.toDouble() ?? 0.0) : 0.0,
      longitude: json['longitude'] != null ? (num.tryParse(json['longitude'].toString())?.toDouble() ?? 0.0) : 0.0,
      address: json['address']?.toString() ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == '1',
      avgRating: json['avg_rating'] != null ? (num.tryParse(json['avg_rating'].toString())?.toDouble() ?? 0.0) : 0.0,
      totalReviews: json['total_reviews'] is int ? json['total_reviews'] : int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      basePrice: json['base_price'] is int ? json['base_price'] : int.tryParse(json['base_price']?.toString() ?? '0') ?? 0,
    );
  }
}
