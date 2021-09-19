import 'package:charity/screens/spinkit.dart';
import 'package:charity/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Settings extends StatefulWidget {
  final String uid;
  final String email;

  const Settings({Key key, this.uid, this.email}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //AuthService _auth = new AuthService();
  final fname = new TextEditingController();
  final lname = new TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  String name;
  String email;

  Future changeName(String fname, String lname) async {
    Firestore.instance.collection("Users").document(widget.uid).updateData({
      'fname': fname,
      'lname': lname,
    });
  }

  Future getUserDetails() async {
    Firestore.instance
        .collection("Users")
        .document(widget.uid)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        name = snapshot.data['fname'] + ' ' + snapshot.data['lname'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return name == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Account"),
              backgroundColor: Colors.deepPurple[300],
            ),
            body: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 30),
                      Text(
                        "Account Details",
                        style: TextStyle(color: Colors.black54, fontSize: 25),
                      ),
                      SizedBox(height: 30),
                      // User name
                      Row(children: <Widget>[
                        Text("Name : " + name),
                        SizedBox(width: 10),
                      ]),
                      SizedBox(height: 15),
                      // Email
                      Row(children: <Widget>[
                        Text("Email: " + widget.email),
                        SizedBox(width: 30),
                      ]),
                      SizedBox(height: 15),

                      //Change Username button
                      Container(
                        width: 200,
                        child: RaisedButton(
                          color: Colors.deepPurple[300],
                          child: Text(
                            "Change Username",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            //Alert Box
                            Alert(
                                context: context,
                                title: "Change Name",
                                content: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: fname,
                                      decoration: InputDecoration(
                                        labelText: 'First Name',
                                      ),
                                    ),
                                    TextField(
                                      controller: lname,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Last Name',
                                      ),
                                    ),
                                  ],
                                ),
                                buttons: [
                                  DialogButton(
                                    color: Colors.deepPurple[300],
                                    onPressed: () async {
                                      if (fname.text.isNotEmpty &&
                                          lname.text.isNotEmpty) {
                                        await changeName(
                                            fname.text, lname.text);
                                        Navigator.pop(context);
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Name changed Successfully"),
                                            duration: Duration(seconds: 4),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      "CHANGE",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  )
                                ]).show();
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      //Change Password button
                      Container(
                        width: 200,
                        child: RaisedButton(
                          color: Colors.deepPurple[300],
                          child: Text(
                            "Change password",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await _auth.sendPasswordResetEmail(
                                email: widget.email);
                            //Alert Box
                            Alert(
                                context: context,
                                title: "Done",
                                content: Center(
                                  child: Text(
                                      "We have sent you a password reset email"),
                                ),
                                buttons: [
                                  DialogButton(
                                    color: Colors.deepPurple[300],
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "CANCEL",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  )
                                ]).show();
                          },
                        ),
                      )
                    ]),
              ),
            ),
          );
  }
}
