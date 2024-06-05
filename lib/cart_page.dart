import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_item_model.dart';
import 'cart_item_widget.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class CartPage extends StatefulWidget {
  final int userId;

  CartPage({required this.userId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _addressController = TextEditingController();
  final ValueNotifier<bool> _isAddressValid = ValueNotifier(false);
  bool _isFetchingLocation = false;

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
    _addressController.addListener(_validateAddress);

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _locationData.latitude!,
      _locationData.longitude!,
    );

    Placemark place = placemarks[0];

    setState(() {
      _addressController.text =
          "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      _isFetchingLocation = false;
    });
  }

  Future<List<CartItem>> fetchCartItems() async {
    final response = await http.get(
        Uri.parse('http://192.168.33.171:3001/cart?user_id=${widget.userId}'));

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

  void _checkout(int userId) async {
    String address = _addressController.text;

    try {
      List<Map<String, dynamic>> transactions = cartItems.map((item) {
        return {
          'address': address,
          'product_id': item.productId.toString(),
          'user_id': userId,
          'amount': item.amount,
        };
      }).toList();

      final response = await http.post(
        Uri.parse('http://192.168.33.171:3001/transaction-batch'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'data': transactions}),
      );

      if (response.statusCode == 200) {
        try {
          await _deleteCart(userId);
          print('Checkout successful');
        } catch (e) {
          print('Failed to checkout: $e');
        }
        print('Checkout successful');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Checkout successful')));
        // Navigator.pushNamed(context, '/transactions');
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
      Uri.parse('http://192.168.33.171:3001/cart/$userId'),
    );

    if (response.statusCode == 200) {
      print('Cart items deleted successfully');
    } else {
      throw Exception('Failed to delete cart items');
    }
  }

  @override
  void dispose() {
    _addressController.removeListener(_validateAddress);
    _addressController.dispose();
    _isAddressValid.dispose();
    super.dispose();
  }

  void _validateAddress() {
    _isAddressValid.value = _addressController.text.isNotEmpty;
  }

  int get totalAmount {
    return cartItems.fold(
        0, (total, item) => total + (item.price * item.amount).toInt());
  }

  @override
  Widget build(BuildContext context) {
    int userId = Provider.of<UserProvider>(context).userId;

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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      suffixIcon: _isFetchingLocation
                          ? CircularProgressIndicator()
                          : IconButton(
                              icon: Icon(Icons.location_on),
                              onPressed: _getCurrentLocation,
                            ),
                    ),
                  ),
                ),
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
                  padding: const EdgeInsets.all(16.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isAddressValid,
                    builder: (context, isValid, child) {
                      return ElevatedButton(
                        onPressed: isValid ? () => _checkout(userId) : null,
                        child: Text('Checkout'),
                      );
                    },
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
