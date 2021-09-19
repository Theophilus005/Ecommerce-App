import 'package:charity/screens/spinkit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/signup.dart';
import 'screens/homescreen.dart';
import 'screens/login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/admin.dart';

class Wrapper extends StatelessWidget {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

     final user = Provider.of<FirebaseUser>(context);    
     return user != null ? HomeScreen() : Login();
  }
}