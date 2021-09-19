import 'package:charity/screens/orderModel.dart';
import 'package:charity/screens/spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../details.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

TextStyle textStyle = TextStyle(
  color: Colors.white,
);

var alertStyle = AlertStyle(
  animationType: AnimationType.fromTop,
  isCloseButton: false,
  isOverlayTapDismiss: false,
  descStyle: TextStyle(fontWeight: FontWeight.bold),
  animationDuration: Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(0.0),
    side: BorderSide(
      color: Colors.grey,
    ),
  ),
  titleStyle: TextStyle(
    color: Colors.red,
  ),
);

List<OrderModel> orders;

class _OrdersState extends State<Orders> {
  Future getAllOrders() async {
    Firestore.instance
        .collection("All orders")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        orders = snapshot.documents
            .map((documents) => OrderModel.fromFirestore(documents.data))
            .toList();
      });
    });
  }
  /*
    Firestore.instance
        .collection("Orders")
        .document()
        .collection("user orders")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        orders = snapshot.documents
            .map((documents) => OrderModel.fromFirestore(documents.data))
            .toList();
      });
    }); */
  //print(orders[0].fullName);

  @override
  void initState() {
    getAllOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orders == null
          ? Loading()
          : orders.isEmpty
              ? Center(
                  child: Text("There are no orders yet",
                      style: TextStyle(color: Colors.black54, fontSize: 18)))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: <Widget>[
                      ListView.builder(
                          itemCount: orders.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return OrderTile(
                              name: orders[index].fullName,
                              order: orders[index].order,
                              date: orders[index].timestamp.toDate().toString(),
                              checkComplete: orders[index].status,
                              completeness: () async {
                                Navigator.pop(context);
                                await Firestore.instance
                                    .collection("All orders")
                                    .document(orders[index].id)
                                    .updateData(
                                  {'status': 'Completed'},
                                );
                              },
                              color: orders == null
                                  ? CircularProgressIndicator()
                                  : orders[index].status == "Uncompleted"
                                      ? Colors.black
                                      : Colors.green,
                              seeDetails: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => Details(
                                            name: orders[index].fullName,
                                            contact: orders[index].contact,
                                            cost: orders[index]
                                                .totalprice
                                                .toStringAsFixed(2),
                                            date: orders[index]
                                                .timestamp
                                                .toDate()
                                                .toString(),
                                            deliveryPoint:
                                                orders[index].deliveryPoint,
                                            latitude: orders[index].latitude,
                                            longitude: orders[index].longitude,
                                            order: orders[index].order,
                                            paymentOption:
                                                orders[index].paymentMethod,
                                            quantity: orders[index]
                                                .quantity
                                                .toString() /*quantity: orders[index].quantity*/
                                            )));
                              },
                            );
                          }),
                    ],
                  ),
                ),
      //OrderTile(),
      /* RaisedButton(
            child: Text("check"),
            onPressed: getAllOrders,
          ),
          orders == null ? Text("null") : Text(orders[0].fullName) */
    );
  }
}

class OrderTile extends StatelessWidget {
  final String name;
  final String order;
  final String status;
  final String date;
  final String checkComplete;
  final Function completeness;
  final Function seeDetails;
  final Color color;

  const OrderTile(
      {Key key,
      this.name,
      this.order,
      this.status,
      this.date,
      this.completeness,
      this.seeDetails,
      this.checkComplete,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)]),
      width: double.infinity,
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 20,
                color: color,
              ),
              SizedBox(width: 5),
              Text(checkComplete),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child:
                Text("Order: " + order, style: TextStyle(color: Colors.black)),
          ),

          /// Buttons section
          Row(
            children: <Widget>[
              //See Detials Button
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => Details()));
                },
                child: GestureDetector(
                  onTap: seeDetails,
                  child: Container(
                    width: 80,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black38,
                    ),
                    child: Center(
                      child: Text(
                        "See details",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),

              ///Completed button
              GestureDetector(
                onTap: () {
                  return Alert(
                    context: context,
                    style: alertStyle,
                    type: AlertType.info,
                    title: "Confirmation",
                    desc: "Has this order been delivered successfully?",
                    content: Text("Changes made cannot be changed",
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Yes",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: completeness,
                        color: Color.fromRGBO(0, 179, 134, 1.0),
                        radius: BorderRadius.circular(0.0),
                      ),
                      DialogButton(
                        child: Text(
                          "No",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey,
                        radius: BorderRadius.circular(0.0),
                      ),
                    ],
                  ).show();
                }, //completeness,
                child: Container(
                  width: 80,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      "Completed",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 3),

          //Time
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              date,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
