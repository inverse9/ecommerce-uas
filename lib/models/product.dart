class Product {
  int? id;
  String name;
  double price;
  String description;
  String image;
  //int shop_id;
  // String shop_name;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    //required this.shop_id,
    //required this.shop_name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: json['price'],
        image: json['image']);
    //shop_id: json['shop_id']);
    //shop_name: json['shop_name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      //'shop_id': shop_id,
      //'shop_name': shop_name
    };
  }
}
