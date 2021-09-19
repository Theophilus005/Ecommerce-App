import 'package:charity/screens/homescreen.dart';
import 'package:charity/screens/spinkit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charity/services.dart';
import 'package:provider/provider.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirm = '';
  final fname = new TextEditingController();
  final lname = new TextEditingController();

  String matcherror = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? Loading()
          : Scaffold(
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Text(
                      "SIGN UP",
                      style: GoogleFonts.mcLaren(
                        textStyle: TextStyle(
                            fontSize: 25,
                            color: Colors.deepPurple[400],
                            shadows: [
                              Shadow(
                                  blurRadius: 15, color: Colors.deepPurple[200])
                            ]),
                      ),
                    ),
                    Form(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 20),

                          //Fname Input FIeld
                          Center(
                            child: Container(
                              width: 260,
                              child: TextFormField(
                                controller: fname,
                                validator: (val) => val.isEmpty
                                    ? "This field is required"
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: "First name",
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[100]),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[300]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          //Last name field
                          Center(
                            child: Container(
                              width: 260,
                              child: TextFormField(
                                controller: lname,
                                validator: (val) => val.isEmpty
                                    ? "This field is required"
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: "Last name",
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[100]),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[300]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          //Email Input Field
                          Center(
                            child: Container(
                              width: 260,
                              child: TextFormField(
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                  });
                                },
                                validator: (val) => val.isEmpty
                                    ? "This field is required"
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[100]),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[300]),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 12),
                          //Password Input Field
                          Center(
                            child: Container(
                              width: 260,
                              child: TextFormField(
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                                validator: (val) => val.length < 6
                                    ? "Password must be 6+ characters long"
                                    : null,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[100]),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[300]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          //Confirm Password Field

                          Center(
                            child: Container(
                              width: 260,
                              child: TextFormField(
                                onChanged: (val) {
                                  setState(() {
                                    confirm = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  labelText: "Confirm Password",
                                  labelStyle: TextStyle(color: Colors.black38),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[100]),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurple[300]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            matcherror,
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                if (password == confirm) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  dynamic result = await _auth
                                      .registerInWithEmailAndPassword(
                                    email,
                                    password,
                                  );
                                  await _auth.userInfo(fname.text, lname.text);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()));

                                  if (result == null) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                } else {
                                  print("Passwords do not match");
                                  setState(() {
                                    matcherror = "Passwords do not match";
                                  });
                                }
                              },
                              child: Container(
                                  height: 60,
                                  width: 260,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.deepPurple[300]),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.person_add,
                                          color: Colors.white, size: 42),
                                      SizedBox(width: 20),
                                      Text(
                                        "SIGN UP",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: Container(
                                child: Text(
                              "Already have an Account?, sign in",
                              style: TextStyle(
                                color: Colors.deepPurple[200],
                              ),
                            )),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
