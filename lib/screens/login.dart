import 'package:charity/screens/admin.dart';
import 'package:charity/screens/homescreen.dart';
import 'package:charity/screens/passwordReset.dart';
import 'package:charity/screens/spinkit.dart';
import 'package:charity/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  final bool isLoggedOut;

  const Login({Key key, this.isLoggedOut}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

final AuthService _auth = AuthService();

String email = '';
String password = '';

bool isLoading = false;

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    if (widget.isLoggedOut == true) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return SafeArea(
      child: isLoading
          ? Loading()
          : user == null
              ? Scaffold(
                  body: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 90),
                        Text(
                          "LOG IN",
                          style: GoogleFonts.mcLaren(
                            textStyle: TextStyle(
                                fontSize: 25,
                                color: Colors.deepPurple[400],
                                shadows: [
                                  Shadow(
                                      blurRadius: 15,
                                      color: Colors.deepPurple[200])
                                ]),
                          ),
                        ),
                        SizedBox(height: 15),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 20),
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
                                        ? 'This field is required'
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email),
                                      labelText: "Email",
                                      labelStyle:
                                          TextStyle(color: Colors.black38),
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
                                        ? 'Password must be 6+ characters long'
                                        : null,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock),
                                      labelText: "Password",
                                      labelStyle:
                                          TextStyle(color: Colors.black38),
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
                              SizedBox(
                                height: 12,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              PasswordReset()));
                                },
                                child: Container(
                                  child: Text(
                                    "Forgot Password?",
                                    style: GoogleFonts.mcLaren(
                                      textStyle: TextStyle(
                                        color: Colors.deepPurple[200],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Log in button
                              SizedBox(height: 15),
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState.validate()) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      dynamic result = await _auth
                                          .loginInWithEmailAndPassword(
                                              email, password);
                                      if (result == null) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Login()));
                                      }

                                      if (await result.email != null &&
                                              await result.email !=
                                                  "admin@gmail.com" ||
                                          result.email !=
                                              'theophilito@gmail.com') {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                        email: result.email)));
                                      }
                                      if (await result.email != null &&
                                              await result.email ==
                                                  "admin@gmail.com" ||
                                          result.email ==
                                              'theophilito@gmail.com') {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AdminPanel()));
                                      }
                                    }
                                  },
                                  child: Container(
                                      height: 60,
                                      width: 260,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.deepPurple[300]),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.person_add,
                                              color: Colors.white, size: 42),
                                          SizedBox(width: 20),
                                          Text(
                                            "LOG IN ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUp(),
                                    ),
                                  );
                                },
                                child: Container(
                                    child: Text(
                                  "Don't have an Account?, sign up",
                                  style: GoogleFonts.mcLaren(
                                    textStyle: TextStyle(
                                        color: Colors.deepPurple[200]),
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
                )
              : Loading(),
    );
  }
}
