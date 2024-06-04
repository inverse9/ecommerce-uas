import 'package:flutter/material.dart';
import 'cart_item_model.dart';

class CartItemWidget extends StatefulWidget {
  final CartItem cartItem;
  final ValueChanged<int> onUpdateAmount;

  CartItemWidget({required this.cartItem, required this.onUpdateAmount});

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  late int _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.cartItem.amount; // Initialize with the initial amount
  }

  void _incrementAmount() {
    setState(() {
      _amount++;
    });
    widget.onUpdateAmount(_amount);
  }

  void _decrementAmount() {
    if (_amount > 1) {
      setState(() {
        _amount--;
      });
      widget.onUpdateAmount(_amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(widget.cartItem.image),
      title: Text(widget.cartItem.productName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rp${widget.cartItem.price}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _decrementAmount,
              ),
              Text('$_amount'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _incrementAmount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
