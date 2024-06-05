import 'package:ecommerce/login.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/cart_page.dart';
import 'package:ecommerce/item_details.dart';
import 'package:ecommerce/main_screen.dart';
import 'package:ecommerce/logout_page.dart';
import 'package:ecommerce/transactions_page.dart';
import 'package:provider/provider.dart';

import 'user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int userId = Provider.of<UserProvider>(context).userId;
    return MaterialApp(
      title: 'e-commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/main-screen': (context) => MainScreen(),
        '/details': (context) => ItemDetails(),
        '/logout': (context) => LogoutPage(),
        '/transactions': (context) => TransactionsPage(userId: userId),
        '/cart': (context) => CartPage(userId: userId),
      },
    );
  }
}
