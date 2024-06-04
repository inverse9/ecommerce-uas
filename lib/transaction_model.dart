import 'package:flutter/material.dart';

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
