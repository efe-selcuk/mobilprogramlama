class Flower {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final int stockQuantity;

  Flower({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.stockQuantity,
  });

  // Convert Flower object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'stockQuantity': stockQuantity,
    };
  }

  // Create a Flower object from a Firestore document
  factory Flower.fromMap(Map<String, dynamic> map, String documentId) {
    return Flower(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      stockQuantity: map['stockQuantity'] ?? 0,
    );
  }
} 