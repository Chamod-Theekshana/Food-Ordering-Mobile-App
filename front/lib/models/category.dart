class Category {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final bool active;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.active,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'active': active,
    };
  }
}