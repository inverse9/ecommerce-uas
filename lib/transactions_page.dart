import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Transaction {
  final int id;
  final String address;
  final String createdAt;
  final int productId;
  final String productName;
  final String productImage;
  final int userId;
  final String userName;
  final int amount;

  Transaction({
    required this.id,
    required this.address,
    required this.createdAt,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.userId,
    required this.userName,
    required this.amount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      address: json['address'],
      createdAt: json['created_at'],
      productId: json['product_id'],
      productName: json['productName'],
      productImage: json['productImage'],
      userId: json['user_id'],
      userName: json['userName'],
      amount: json['amount'],
    );
  }
}

class TransactionsPage extends StatefulWidget {
  final int userId;

  TransactionsPage({required this.userId});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late Future<List<Transaction>> _futureTransaction;

  @override
  void initState() {
    super.initState();
    _futureTransaction = fetchTransactions();
  }

  Future<List<Transaction>> fetchTransactions() async {
    final response = await http
        .get(Uri.parse('http://localhost:3001/transactions/${widget.userId}'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Transaction.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load transaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _futureTransaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Transaction> transactions = snapshot.data!;
            print(transactions);
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(transactions[index].productImage),
                  title: Text(transactions[index].productName),
                  // subtitle: Text('Price: ${transactions[index].price}'),
                  trailing: Text('Date: ${transactions[index].createdAt}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
