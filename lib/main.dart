import 'package:flutter/material.dart';
import 'package:ecommerce/cart_page.dart';
import 'package:ecommerce/item_details.dart';
import 'package:ecommerce/main_screen.dart';
import 'package:ecommerce/logout_page.dart';
import 'package:ecommerce/transactions_page.dart';

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
