import 'package:charity/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import './AdminTabs/food.dart';
import './AdminTabs/orders.dart';
import './AdminTabs/stats.dart';
import 'homescreen.dart';
import 'package:charity/services.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

final AuthService _auth = AuthService();

Color primary = Colors.deepPurple[300];

FlutterTts flutterTts = FlutterTts();

speak() async {
  await flutterTts.speak(
      "This is the administrator panel of the application. It has three tabs. The first tab, the products tab is where you add the things you want to sell. You have to first create a category and then you can add the products. The orders tab is where orders will show as and when customers order them. The stats section shows certain statistical progress as you use the app. Also, at the top right corner, there are three buttons. The first one is to switch between the homescreen of the app and the administrator panel. You are the only one who can switch between the two screens. The second one is to send push notifications your customers. Once you send a notification, anyone who has installed the app will receive it. You can schedule the notifications as well. It works both online and offline");
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          title: Text("ADMIN PANEL"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.swap_horizontal_circle, size: 35),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            SizedBox(width: 5),
            IconButton(
                icon: Icon(Icons.notifications_active, size: 35),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Notifications()));
                }),
            IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white, size: 35),
                onPressed: () {
                  speak();
                }),
            SizedBox(width: 5)
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.fastfood),
                text: "Products",
              ),
              Tab(
                icon: Icon(
                  Icons.list,
                ),
                text: "Orders",
              ),
              Tab(icon: Icon(Icons.show_chart), text: "Stats"),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Food(),
            Orders(),
            Stats(),
          ],
        ),
      ),
    );
  }
}
