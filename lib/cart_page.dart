import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item.dart';
import 'cart_item_widget.dart';

class CartPage extends StatefulWidget {
  final int userId;

  CartPage({required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> futureCartItems;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    futureCartItems = fetchCartItems();
    futureCartItems.then((items) {
      setState(() {
        cartItems = items;
      });
    });
  }

  Future<List<CartItem>> fetchCartItems() async {
    final response = await http
        .get(Uri.parse('http://localhost:3001/cart?user_id=${widget.userId}'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  void _updateAmount(int index, int newAmount) {
    setState(() {
      cartItems[index].amount = newAmount;
    });
  }

  void _checkout() async {
    try {
      List<Map<String, dynamic>> transactions = cartItems.map((item) {
        return {
          'address': 'Some address', // Replace with actual address if needed
          'product_id': item.productId.toString(),
          'user_id': widget.userId,
          'amount': item.amount,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('http://localhost:3001/transaction-batch'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'data': transactions}),
      );

      if (response.statusCode == 200) {
        try {
          // Make the POST request to '/transaction-batch' with the data

          // After successful checkout, delete the cart items
          await _deleteCart(1); // Assuming user ID is 1 for now
          print('Checkout successful');
        } catch (e) {
          print('Failed to checkout: $e');
        }
        print('Checkout successful');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Checkout successful')));
        Navigator.pushNamed(context, '/transactions');
      } else {
        throw Exception('Failed to checkout');
      }
    } catch (e) {
      print('Failed to checkout: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
    }
  }

  Future<void> _deleteCart(int userId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3001/cart/$userId'),
    );

    if (response.statusCode == 200) {
      print('Cart items deleted successfully');
    } else {
      throw Exception('Failed to delete cart items');
    }
  }

  int get totalAmount {
    return cartItems.fold(
        0, (total, item) => total + (item.price * item.amount).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: futureCartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items in cart'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == cartItems.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Total: Rp$totalAmount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return CartItemWidget(
                          cartItem: cartItems[index],
                          onUpdateAmount: (newAmount) {
                            _updateAmount(index, newAmount);
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _checkout,
                      child: Text('Checkout'),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
