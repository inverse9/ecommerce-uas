import 'package:ecommerce/cart_page.dart';
import 'package:ecommerce/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ItemDetails extends StatefulWidget {
  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  int _counter = 1;

  Future<void> addToCart(int userId, int productId, int amount) async {
    final response = await http.post(
      Uri.parse('http://localhost:3001/cart'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'user_id': userId,
        'product_id': productId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      print('Item added to cart');
    } else {
      throw Exception('Failed to add item to cart');
    }
  }

  void _buyNow(BuildContext context, int productId, int amount) async {
    int userId =
        1; // Assuming a static user ID for now; replace with actual logic
    try {
      await addToCart(userId, productId, amount);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CartPage(userId: userId)),
      );
    } catch (e) {
      print('Failed to add to cart: $e');
    }
  }

  void _showConfirmationDialog(
      BuildContext context, int productId, int amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to buy this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _buyNow(context, productId, amount);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String image = args['image'];
    final String name = args['name'];
    final double price = args['price'];
    final String description = args['description'];
    final int productId = args['id']; // Ensure product ID is passed

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$name - Rp${price}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(description),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_counter > 1) _counter--;
                              });
                            },
                          ),
                          Text(
                            '$_counter',
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _counter++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context, productId, _counter);
                },
                child: Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
