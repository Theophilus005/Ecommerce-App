import 'package:cloud_firestore/cloud_firestore.dart';

class RecentModel {
  final String fullName;
  final String deliveryPoint;
  final String contact;
  final String order;
  final double totalprice;
  final double latitude;
  final double longitude;
  final String paymentMethod;
  final Timestamp timestamp;
  final String status;
  final int quantity;
  final String id;
  final String imageUrl;
  RecentModel(
      {this.fullName,
      this.deliveryPoint,
      this.contact,
      this.order,
      this.totalprice,
      this.latitude,
      this.longitude,
      this.paymentMethod,
      this.timestamp,
      this.quantity,
      this.status,
      this.id,
      this.imageUrl});

  RecentModel.fromFirestore(Map<String, dynamic> firestore)
      : fullName = firestore['full name'],
        contact = firestore['contact'],
        deliveryPoint = firestore['delivery point'],
        order = firestore['Order'],
        totalprice = firestore['total cost'],
        latitude = firestore['latitude'],
        longitude = firestore['logitude'],
        paymentMethod = firestore['payment method'],
        timestamp = firestore['timestamp'],
        status = firestore['status'],
        quantity = firestore['quantity'],
        id = firestore['id'],
        imageUrl = firestore['imageUrl'];
}
