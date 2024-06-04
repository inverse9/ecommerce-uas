import 'package:flutter/material.dart';
import 'pages/product_list_page.dart';
import 'pages/add_product_page.dart';
import 'pages/edit_product_page.dart';
import 'models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Produk',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          background: Colors.grey[200],
        ),
      ),
      home: ProductListPage(),
      routes: {
        '/add-product': (context) => AddProductPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-product') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => EditProductPage(product: product),
          );
        }
        return null;
      },
    );
  }
}
