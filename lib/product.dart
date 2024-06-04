class Product {
  final int id;
  final int shopId;
  final String shopName;
  final String name;
  final String description;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      shopId: json['shop_id'] as int,
      shopName: json['shopName'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
    );
  }
}
