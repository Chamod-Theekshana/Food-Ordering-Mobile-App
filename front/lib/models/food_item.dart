import 'category.dart';

class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final Category? category;
  final bool available;
  final int stockQuantity;
  final double averageRating;
  final int ratingCount;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.category,
    required this.available,
    required this.stockQuantity,
    required this.averageRating,
    required this.ratingCount,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      available: json['available'],
      stockQuantity: json['stockQuantity'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category?.toJson(),
      'available': available,
      'stockQuantity': stockQuantity,
    };
  }
}