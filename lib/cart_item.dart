class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int amount;
  final String userName;
  final String productName;
  final double price;
  final String image;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.amount,
    required this.userName,
    required this.productName,
    required this.price,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      productId: json['product_id'] as int,
      amount: json['amount'] as int,
      userName: json['userName'] as String,
      productName: json['productName'] as String,
      image: json['productImage'] as String,
      price: (json['productPrice'] as num).toDouble(),
    );
  }
}
