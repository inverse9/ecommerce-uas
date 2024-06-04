import 'package:flutter/material.dart';
import 'product.dart';

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
