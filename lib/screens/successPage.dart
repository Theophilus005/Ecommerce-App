import 'package:charity/screens/homescreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Success extends StatelessWidget {
  final String fname;
  final String lname;

  const Success({Key key, this.fname, this.lname}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: Image.asset("assets/images/greentick.png"),
              width: 260,
              height: 260,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                fname +
                    " " +
                    lname +
                    "," +
                    " your order has been place successfully. We will soon deliver it to you. Thanks for using Fast Delivery Service. We have sent your receipt to your email. Thank You.",
                style: TextStyle(fontSize: 18),
              ),
            ),

            //Okay Button
            Container(
              width: 120,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: RaisedButton(
                  color: Colors.green,
                  child: Text("Okay",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        CupertinoPageRoute(builder: (context) => HomeScreen()));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
