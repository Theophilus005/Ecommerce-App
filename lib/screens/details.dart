import 'package:charity/screens/adminMap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatelessWidget {
  final String name;
  final String order;
  final String quantity;
  final String cost;
  final String paymentOption;
  final String contact;
  final String date;
  final String deliveryPoint;
  final double latitude;
  final double longitude;

  const Details(
      {Key key,
      this.name,
      this.order,
      this.quantity,
      this.cost,
      this.paymentOption,
      this.contact,
      this.date,
      this.deliveryPoint,
      this.latitude,
      this.longitude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterTts flutterTts = FlutterTts();
    speak() async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.speak(
          "This page contains every detail about the order made by the customer. You can call the customer by just tapping on the phone icon");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        backgroundColor: Colors.deepPurple[300],
        actions: <Widget>[
          IconButton(
            icon: FaIcon(Icons.info_outline, color: Colors.white, size: 35),
            onPressed: speak,
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Name: " + name.toUpperCase()),
                Text("Order: " + order),
                Text("Quantity: " + quantity),
                Text("Total Cost: " + "GH¢" + cost),
                Text("Payment Method: " + paymentOption),
                Row(
                  children: <Widget>[
                    Text("Contact: " + contact),
                    SizedBox(width: 6),
                    IconButton(
                      icon: Icon(Icons.phone, color: Colors.green),
                      onPressed: () async {
                        await launch("tel://" + contact.toString());
                      },
                    ),
                    Text(
                      "<--Call",
                      style: TextStyle(color: Colors.black45),
                    ),
                  ],
                ),
                Text("Date Ordered: " + date),
                Text("Delivery Point: " + deliveryPoint),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: RaisedButton(
                    color: Colors.deepPurple[300],
                    child: Text(
                      "See Location on Map",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => AdminMap(
                                  latitude: latitude,
                                  longitude: longitude,
                                  deliveryPoint: deliveryPoint)));
                      print(latitude);
                      print(longitude);
                    },
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
