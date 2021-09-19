import 'dart:io';
import 'dart:math';

import 'package:charity/screens/successPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:rave/rave.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class Bill extends StatefulWidget {
  final String name;
  final int quantity;
  final double price;
  final double positionLatitude;
  final double positionLongitude;
  final String imageUrl;
  final String email;

  const Bill(
      {Key key,
      this.name,
      this.quantity,
      this.price,
      this.positionLatitude,
      this.positionLongitude,
      this.imageUrl,
      this.email})
      : super(key: key);

  @override
  _BillState createState() => _BillState();
}

class _BillState extends State<Bill> {
// Dropdown Payment Options
  List<DropdownMenuItem> dropdownItems = [
    DropdownMenuItem(
      child: Text("MTN Mobile Money"),
      value: "MTN",
    ),
    DropdownMenuItem(
      child: Text("Tigo Cash"),
      value: "TIGO",
    ),
    DropdownMenuItem(
      child: Text("Vodafone Cash"),
      value: "VODAFONE",
    ),
    DropdownMenuItem(
      child: Text("Payment On Delivery"),
      value: "POD",
    )
  ];

  //Drop down Value
  String paymentOption;
  String address;
  final contact = new TextEditingController();

  chargeCustomer(String network, String number, String amount, String fname,
      String lname) {
    String chargeUrl =
        "https://api.flutterwave.com/v3/charges?type=mobile_money_ghana";

    return http.post(chargeUrl,
        body: ({
          "tx_ref": "MC-" + DateTime.now().toString(),
          "amount": amount,
          "currency": "GHS",
          "network": network,
          "email": "theophilito@ymail.com",
          "phone_number": number,
          "fullname": fname + " " + lname
        }),
        headers: {
          HttpHeaders.authorizationHeader:
              "FLWSECK-4e2df16650461922f0f588a30d4883dc-X"
        }).then((response) async {
      var data = json.decode(response.body);
      print(response.statusCode);
      print(response.body);
      print(data['meta']['authorization']['redirect']);
      await launch(data['meta']['authorization']['redirect'],
          enableJavaScript: true, forceWebView: true);
    });
  }

  placeOrder() async {
    final id = Random().nextInt(500000000).toString();
    Firestore.instance.collection("All orders").document(id).setData({
      "full name": fname + " " + lname,
      "Order": widget.name,
      "total cost": finalPrice,
      "contact": contact.text,
      "payment method": paymentOption,
      "delivery point": address,
      "latitude": widget.positionLatitude,
      "longitude": widget.positionLongitude,
      "timestamp": DateTime.now(),
      "status": "Uncompleted",
      "quantity": quantity,
      "id": id,
      "imageUrl": widget.imageUrl,
    });
    return id;
  }

  userOrders(String document) async {
    Firestore.instance
        .collection("User Orders")
        .document(document)
        .collection("My orders")
        .document()
        .setData({
      "full name": fname + " " + lname,
      "Order": widget.name,
      "total cost": finalPrice,
      "payment method": paymentOption,
      "delivery point": address,
      "latitude : ": widget.positionLatitude,
      "longitude : ": widget.positionLongitude,
      "timestamp": DateTime.now(),
      "quantity": quantity,
    });
  }

  double lat = -73.989;

  Future sendEmail(String price, String name, String product, String quantity,
      String orderId, String paymentOption) async {
    String username = 'theophilito5@gmail.com';
    String password = 'xanthosis';

    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.

    // Create our message.
    final message = Message()
      ..from = Address(username, "Theophilus from Fast Delivery")
      ..recipients.add(widget.email)
      ..subject = 'Order Receipt'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<h1>Hello " +
          name +
          "</h1>\n<h3>Here is the receipt for the order you made </h3><img src='https://firebasestorage.googleapis.com/v0/b/food-delivery-app-c9996.appspot.com/o/logo%2Flogo.png?alt=media&token=03f47f78-8da3-44e0-94c9-2b8adce370e5'></img>\n <p>Order id: " +
          orderId +
          "\n</p><p>Product: " +
          product +
          "\n</p><p>Quantity: " +
          quantity +
          "\n</p><p>Price: " +
          price +
          "<p>Payment Option: " +
          paymentOption +
          "</p>" +
          "\n<br><hr><h3 style='font-size:20px'>Thank you for using our delivery service &#128521;\n</h3>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  geocode() async {
    String latitude = widget.positionLatitude.toString();
    String longitude = widget.positionLongitude.toString();
    var response = await http.get(
        "https://us1.locationiq.com/v1/reverse.php?key=0e046a0ea3e9fb&format=json&lat=" +
            latitude +
            "&lon=" +
            longitude);

    var decoded = json.decode(response.body);
    print(decoded['display_name']);
    String displayname = decoded['display_name'];

    // String countryName = decoded['features'][0]['context'][3]['text'];
    print(decoded);
    //print("${first.featureName} : ${first.addressLine}");
    //print(first.countryName);
    setState(() {
      address = displayname;
    });
    print(latitude);
    print(longitude);
  }

  int quantity = 1;
  double initialPrice;
  double finalPrice;
  //double price = widget.price;

  @override
  void initState() {
    initialPrice = widget.price;
    finalPrice = widget.price;
    geocode();
    super.initState();
  }

  Map userDetails;
  String fname;
  String lname;

  getUserDetails(String uid) async {
    await Firestore.instance
        .collection("Users")
        .document(uid)
        .get()
        .then((document) => setState(() {
              userDetails = document.data;
            }));

    print(userDetails);
    setState(() {
      fname = userDetails['fname'];
      lname = userDetails['lname'];
    });
    /*  print(userDetails['fname']);
    print(userDetails['lname']);
    print(userDetails['uid']); */
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    SizedBox(width: 20),
                    Text(
                      "Payment Info",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.name,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Quantity: ",
                            style: TextStyle(
                              fontSize: 17,
                            )),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () {
                        if (quantity != 1) {
                          setState(() {
                            quantity--;
                            //reset price to initial value first
                            initialPrice = widget.price;
                            finalPrice = quantity * initialPrice;
                          });
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Text(
                        '$quantity',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: () {
                        setState(() {
                          quantity++;
                          initialPrice = widget.price;
                          finalPrice = quantity * initialPrice;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "Total Price: ",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      "GH¢" + finalPrice.toStringAsFixed(2),
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(height: 0),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text("Delivery Point ",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black54,
                              )),
                          FaIcon(FontAwesomeIcons.home,
                              color: Colors.green, size: 20),
                        ],
                      ),
                      SizedBox(height: 10),
                      address == null
                          ? Text("Getting Location...")
                          : Text(address,
                              maxLines: 3,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),
                    ],
                  ),
                ),
                SizedBox(height: 5),

                // Netowork logos
                Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Choose Your Payment Option",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 13)),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Note: Momo deactivated",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 13)),
                    ),
                    SizedBox(height: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: 70,
                          height: 50,
                          child: Image.asset("assets/networks/mtn.png",
                              fit: BoxFit.fill),
                        ),
                        Container(
                          width: 60,
                          height: 50,
                          child: Image.asset("assets/networks/vodafone.png",
                              fit: BoxFit.fill),
                        ),
                        Container(
                          width: 80,
                          height: 50,
                          child: Image.asset("assets/networks/tigo.png",
                              fit: BoxFit.fill),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                    hint: Text("Payment Option",
                        style: TextStyle(color: Colors.black54)),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple[300])),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple[300])),
                    ),
                    items: dropdownItems,
                    onChanged: (val) {
                      setState(() {
                        paymentOption = val;
                      });
                    }),
                SizedBox(height: 2),
                GestureDetector(
                  onTap: () async {
                    //chargeCustomer();
                    if (address != null) {
                      if (paymentOption == "MTN" ||
                          paymentOption == "VODAFONE" ||
                          paymentOption == "TIGO") {
                        return Alert(
                          context: context,
                          title: "LET'S GET YOUR CONTACT",
                          buttons: [
                            DialogButton(
                              color: Colors.deepPurple[400],
                              child: Text("Complete Order",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              onPressed: () async {
                                //chargeCustomer();
                                await getUserDetails(user.uid);
                                chargeCustomer(paymentOption, contact.text,
                                    finalPrice.toString(), fname, lname);
                              },
                            )
                          ],
                          content: Column(
                            children: <Widget>[
                              Text("Payment Option: " + paymentOption,
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Text("Mobile money number",
                                  style: TextStyle(fontSize: 16)),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 20, bottom: 15, left: 15, right: 15),
                                width: 240,
                                height: 40,
                                decoration: BoxDecoration(
                                    //color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        left: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        bottom: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        right: BorderSide(
                                            color: Colors.deepPurple[300]))),
                                child: TextField(
                                  controller: contact,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    hintText: "Momo No.",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Text("We will contact you through this number",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ).show();

                        //Payment On Delivery Alert Box
                      } else if (paymentOption == "POD") {
                        return Alert(
                          context: context,
                          title: "LET'S GET YOUR CONTACT",
                          buttons: [
                            DialogButton(
                                color: Colors.deepPurple[400],
                                child: Text("Complete Order",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                onPressed: () async {
                                  await getUserDetails(user.uid);
                                  var orderId = await placeOrder();
                                  userOrders(user.uid);
                                  sendEmail(
                                      widget.price.toStringAsFixed(2),
                                      fname,
                                      widget.name,
                                      widget.quantity.toString(),
                                      orderId,
                                      paymentOption);
                                  Navigator.pushReplacement(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => Success(
                                              fname: fname, lname: lname)));
                                  /*chargeCustomer(paymentOption, contact.text,
                                    finalPrice.toString(), fname, lname);*/
                                })
                          ],
                          content: Column(
                            children: <Widget>[
                              Text("Payment On Delivery",
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Text("Contact Number:",
                                  style: TextStyle(fontSize: 16)),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 20, bottom: 15, left: 15, right: 15),
                                width: 240,
                                height: 40,
                                decoration: BoxDecoration(
                                    //color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border(
                                        top: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        left: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        bottom: BorderSide(
                                            color: Colors.deepPurple[300]),
                                        right: BorderSide(
                                            color: Colors.deepPurple[300]))),
                                child: TextField(
                                  controller: contact,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 10, right: 10, bottom: 10),
                                    hintText: "Contact number",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Text("We will contact you through this number",
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ).show();
                      } else {
                        return Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("No payment option selected"),
                          duration: Duration(seconds: 4),
                        ));
                      }
                    }
                  },
                  child: Container(
                    //width: double.infinity,
                    width: double.infinity,
                    height: 45,
                    color: Colors.deepPurple[300],
                    child: Center(
                      child: Text(
                        "Place Order",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                /* RaisedButton(
                  child: Text("check"),
                  onPressed: () async {
                    //print());
                    print(widget.email);
                    sendEmail("10", "Mansa", "shirt", "1", "2000", "MTN");
                  },
                ),*/
              ]),
        ),
      ),
    );
  }
}
