import 'package:flutter/material.dart';

class ReviewModel {
  final String name;
  final String date;
  final String message;

  ReviewModel(this.name, this.date, this.message);

  ReviewModel.fromFirestore(Map<String, dynamic> firestore)
      : name = firestore['name'],
        date = firestore['date'],
        message = firestore['message'];
}
