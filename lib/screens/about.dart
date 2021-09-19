import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Developer"),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.asset("assets/images/thinking.png"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "If you would like to use this app for commercial purposes and would like the MOMO to be activated. Please send an email to theophilito@ymail.com. Bank and card payments can be integrated as well.",
                    style: TextStyle(fontSize: 17)),
              ),
            ]));
  }
}
