import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrderModel {
  final String order;
  final double totalprice;
  final String paymentMethod;
  final Timestamp timestamp;

  final int quantity;

  MyOrderModel({
    this.order,
    this.totalprice,
    this.paymentMethod,
    this.timestamp,
    this.quantity,
  });

  MyOrderModel.fromFirestore(Map<String, dynamic> firestore)
      : order = firestore['Order'],
        totalprice = firestore['total cost'],
        paymentMethod = firestore['payment method'],
        timestamp = firestore['timestamp'],
        quantity = firestore['quantity'];
}
