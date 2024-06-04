import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
      routes: {
        '/details': (context) => ItemDetails(),
        '/logout': (context) => LogoutPage(),
        '/transactions': (context) => TransactionsPage(),
        '/cart': (context) => CartPage(userId: 1), // Assuming user ID 1 for now
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  MainScreen({this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static List<Widget> _pages = <Widget>[
    HomePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://localhost:3001/products'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];
      return data.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Product> products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return GridItem(products[index]);
              },
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final Product product;

  GridItem(this.product);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: {
            'image': product.image,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'id': product.id,
          },
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}

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

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Center(
        child: Text('This is the Transactions page.'),
      ),
    );
  }
}

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: Text(
          'You have been logged out',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

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

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Username'),
            subtitle: Text('User123'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text('user@example.com'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text('+123 456 789'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          ListTile(
            title: Text('Transactions'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransactionsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
        ],
      ),
    );
  }
}
