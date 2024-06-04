import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transaction_model.dart';

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
    print(widget.userId);

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
