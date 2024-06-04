import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item.dart';

class CartPage extends StatelessWidget {
  final int userId;

  CartPage({required this.userId});

  Future<List<CartItem>> fetchCartItems() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/cart?user_id=$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: fetchCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in cart'));
          } else {
            List<CartItem> products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(products[index].image),
                  title: Text(products[index].productName),
                  subtitle: Text('Rp${products[index].price}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
