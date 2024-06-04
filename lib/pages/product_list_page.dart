import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ApiService apiService = ApiService();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      List<Product> productList = await apiService.getProducts();
      setState(() {
        // Batasi jumlah data yang ditampilkan menjadi 6
        products = productList.take(6).toList();
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Produk',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.start, // Set rata kiri
                          spacing: 16.0, // spasi horizontal antara children
                          runSpacing: 16.0, // spasi vertikal antara baris
                          children: products.map((product) {
                            return Card(
                              elevation: 4,
                              color: Colors.grey[400],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Tampilkan gambar di sisi kiri
                                    Image.network(
                                      product.image,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                        width:
                                            16), // Spasi antara gambar dan detail
                                    // Tampilkan detail produk di sisi kanan
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('ID: ${product.id}'),
                                          Text(
                                            'Name: ${product.name}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Price: Rp. ${product.price}'),
                                          Text(
                                              'Description: ${product.description}'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProductPage(
                                                              product: product),
                                                    ),
                                                  ).then(
                                                      (_) => fetchProducts());
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.white),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Confirm Delete'),
                                                        content: Text(
                                                            'Are you sure you want to delete this product?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              apiService
                                                                  .deleteProduct(
                                                                      product
                                                                          .id!)
                                                                  .then((_) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                fetchProducts();
                                                              });
                                                            },
                                                            child:
                                                                Text('Delete'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                            height:
                                80), // Spasi untuk memberi ruang pada tombol
                      ],
                    ),
                  ),
                ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                ).then((_) => fetchProducts());
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
