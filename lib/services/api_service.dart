import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/products';

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(
          'Response: $jsonResponse'); // Tambahkan ini untuk memeriksa respons API
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('data')) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(
          'Response: $jsonResponse'); // Tambahkan ini untuk memeriksa respons API
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load product');
    }
  }

  Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      print(
          'Response: $jsonResponse'); // Tambahkan ini untuk memeriksa respons API
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to create product');
    }
  }

  Future<Product> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(
          'Response: $jsonResponse'); // Tambahkan ini untuk memeriksa respons API
      return Product.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      print('Product deleted'); // Tambahkan ini untuk memeriksa respons API
      return;
    } else {
      throw Exception('Failed to delete product');
    }
  }
}
