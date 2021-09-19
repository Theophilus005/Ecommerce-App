import 'package:animated_splash/animated_splash.dart';
import 'package:charity/screens/AdminTabs/food.dart';
import 'package:charity/screens/addfood.dart';
import 'package:charity/screens/insert.dart';
import 'package:charity/screens/map.dart';
import 'package:charity/screens/mapPage.dart';
import 'package:charity/screens/orderScreen.dart';
import 'package:charity/screens/signup.dart';
import 'package:flutter/material.dart';
import 'screens/BillingScreen.dart';
import 'screens/homescreen.dart';
import 'screens/login.dart';
import 'screens/admin.dart';
import 'screens/AdminTabs/items.dart';
import 'package:provider/provider.dart';
import 'services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wrapper.dart';
import 'screens/spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().status,
      child: MaterialApp(
        title: 'Fast Delivery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: AnimatedSplash(
          imagePath: 'assets/images/logo.png',
          home: Wrapper(),
          duration: 5000,
          type: AnimatedSplashType.StaticDuration,
        ),
      ),
    );
  }
}
