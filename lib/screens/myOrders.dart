import 'package:charity/screens/myOrderModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyOrders extends StatefulWidget {
  final String uid;

  const MyOrders({Key key, this.uid}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

List<MyOrderModel> myOrders;

class _MyOrdersState extends State<MyOrders> {
  Future getMyOrders() async {
    Firestore.instance
        .collection("User Orders")
        .document(widget.uid)
        .collection("My orders")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        myOrders = snapshot.documents
            .map((documents) => MyOrderModel.fromFirestore(documents.data))
            .toList();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: myOrders.isEmpty
          ? Center(
              child: Text("You have no orders",
                  style: TextStyle(color: Colors.black54, fontSize: 18)))
          : ListView.builder(
              itemCount: myOrders.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return MyOrderTile(
                    title: myOrders[index].order,
                    quantity: myOrders[index].quantity,
                    cost: myOrders[index].totalprice,
                    paymentOption: myOrders[index].paymentMethod,
                    date: myOrders[index].timestamp);
              }),
    );
  }
}

class MyOrderTile extends StatelessWidget {
  final String title;
  final int quantity;
  final double cost;
  final String paymentOption;
  final Timestamp date;

  const MyOrderTile(
      {Key key,
      this.title,
      this.quantity,
      this.cost,
      this.paymentOption,
      this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title,
                  style: TextStyle(color: Colors.black54, fontSize: 18)),
              SizedBox(height: 3),
              Text(
                "Quantity: " + quantity.toString(),
                style: TextStyle(color: Colors.black54, fontSize: 17),
              ),
              SizedBox(height: 3),
              Text("Total Cost: GH¢" + cost.toStringAsFixed(2),
                  style: TextStyle(color: Colors.black54, fontSize: 17)),
              SizedBox(height: 3),
              Text("Payment Method: " + paymentOption,
                  style: TextStyle(color: Colors.black54, fontSize: 17)),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1.5,
                color: Colors.black38,
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(date.toDate().toString(),
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
              ),
            ]),
      ),
    );
  }
}
