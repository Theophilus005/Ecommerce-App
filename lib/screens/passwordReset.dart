import 'package:charity/screens/spinkit.dart';
import 'package:charity/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordReset extends StatefulWidget {
  @override
  _PasswordResetState createState() => _PasswordResetState();
}

bool isClicked = false;
bool loading = false;
final FirebaseAuth _auth = FirebaseAuth.instance;
final email = new TextEditingController();

class _PasswordResetState extends State<PasswordReset> {
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Password Reset"),
              backgroundColor: Colors.deepPurple[300],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  isClicked == false
                      ? Center(
                          child: Container(
                              child: TextField(
                            controller: email,
                            decoration: InputDecoration(
                                hintText: "Email",
                                border: InputBorder.none,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple[200],
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple[300]),
                                )),
                          )),
                        )
                      : Container(),
                  SizedBox(height: 25),

                  //Send Email Button
                  isClicked == false
                      ? GestureDetector(
                          onTap: () async {
                            setState(() {
                              loading = true;
                            });
                            await _auth.sendPasswordResetEmail(
                                email: email.text);
                            setState(() {
                              isClicked = true;
                              loading = false;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.deepPurple[300],
                            ),
                            child: Center(
                                child: Text("Send Email",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17))),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 15),

                  // Description Text
                  isClicked == false
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                                "We will send you a link to reset your password.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20,
                                  //shadows: [Shadow(color: Colors.purple[200], blurRadius: 2)],
                                )),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.email, size: 35, color: Colors.grey),
                            Center(
                              child: Text(
                                  "We have sent you a password reset email",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 20,
                                    //shadows: [Shadow(color: Colors.purple[200], blurRadius: 2)],
                                  )),
                            ),
                          ],
                        ),
                ],
              ),
            ));
  }
}
