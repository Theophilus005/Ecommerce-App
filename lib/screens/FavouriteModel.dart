import 'package:flutter/material.dart';

class Favourite {
  final String title;
  final String price;
  final String description;
  final String id;
  final String imageUrl;

  Favourite(this.title, this.price, this.description, this.id, this.imageUrl);

  Favourite.fromFirestore(Map<String, dynamic> firestore)
      : title = firestore['order'],
        price = firestore['price'],
        description = firestore['description'],
        imageUrl = firestore['imageUrl'],
        id = firestore['id'];
}
