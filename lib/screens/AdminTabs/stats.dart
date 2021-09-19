import 'dart:async';

import 'package:charity/screens/homescreen.dart';
import 'package:charity/screens/orderModel2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';

import '../orderModel.dart';

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<OrderModel2> completedOrders;
  List<OrderModel> unCompletedOrders;
  int totalUsers;
  String sample = "sample";

  Future getCompletedOrders() async {
    Firestore.instance
        .collection("All orders")
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        completedOrders = snapshot.documents
            .map((documents) => OrderModel2.fromFirestore(documents.data))
            .toList();
      });
    });
  }

  Future getUncompletedOrders() async {
    Firestore.instance
        .collection("All orders")
        .where('status', isEqualTo: 'Uncompleted')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        unCompletedOrders = snapshot.documents
            .map((documents) => OrderModel.fromFirestore(documents.data))
            .toList();
      });
    });
  }

  Future getTotalUsers() async {
    Firestore.instance.collection("Users").snapshots().listen((snapshot) {
      setState(() {
        totalUsers = snapshot.documents.length;
      });
    });
  }

  int counter = 4;
  double totalMoney = 0;

  Future getTotalMoney() async {
    if (completedOrders != null) {
      for (int i = 0; i < completedOrders.length; i++) {
        setState(() {
          totalMoney = totalMoney + completedOrders[i].totalprice;
        });
      }
    } else {
      Timer.periodic(Duration(seconds: 1), (time) {
        setState(() {
          counter--;
        });
        if (counter == 0) {
          if (completedOrders != null) {
            for (int i = 0; i < completedOrders.length; i++) {
              setState(() {
                totalMoney = totalMoney + completedOrders[i].totalprice;
              });
            }
          }
          time.cancel();
        }
      });
    }
  }

  @override
  void initState() {
    getCompletedOrders();
    getUncompletedOrders();
    getTotalUsers();
    getTotalMoney();
    super.initState();
  }

  Future onNotificationSelected(String payload) async {
    Navigator.pushReplacement(
        context, CupertinoPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)]),
          padding: EdgeInsets.symmetric(horizontal: 15),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Statistics",
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                  SizedBox(width: 50),
                  Icon(Icons.show_chart, color: Colors.green, size: 40),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Uncompleted Orders: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                  unCompletedOrders == null || unCompletedOrders.isEmpty
                      ? Text("0", style: TextStyle(fontSize: 17))
                      : Text(unCompletedOrders.length.toString(),
                          style: TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Completed Orders: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                  completedOrders == null || completedOrders.isEmpty
                      ? Text("0", style: TextStyle(fontSize: 17))
                      : Text(completedOrders.length.toString(),
                          style: TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Total Orders: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                  unCompletedOrders == null || completedOrders == null
                      ? Text("0", style: TextStyle(fontSize: 17))
                      : Text(
                          (unCompletedOrders.length + completedOrders.length)
                              .toString(),
                          style: TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Total Users Signed Up: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                  totalUsers == null
                      ? Text("0", style: TextStyle(fontSize: 17))
                      : Text(totalUsers.toString(),
                          style: TextStyle(fontSize: 17)),
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Total Money Earned: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      )),
                  totalMoney == null
                      ? Text("0", style: TextStyle(fontSize: 17))
                      : Text("GH¢" + totalMoney.toStringAsFixed(2),
                          style: TextStyle(fontSize: 17)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
