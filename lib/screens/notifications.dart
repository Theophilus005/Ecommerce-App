import 'dart:async';
import 'dart:typed_data';

import 'package:day_selector/day_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'homescreen.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  FlutterLocalNotificationsPlugin localNotifications;
  bool _disposed = false;
  bool yes = true;
  bool no = false;
  bool answer = true;

  //Text Editing Controllers
  final title1 = new TextEditingController();
  final title2 = new TextEditingController();
  final title3 = new TextEditingController();
  final title4 = new TextEditingController();

  final body1 = new TextEditingController();
  final body2 = new TextEditingController();
  final body3 = new TextEditingController();
  final body4 = new TextEditingController();

  List<DropdownMenuItem> days = [
    DropdownMenuItem(child: Text("Monday"), value: Day.Monday),
    DropdownMenuItem(child: Text("Tuesday"), value: Day.Tuesday),
    DropdownMenuItem(child: Text("Wednesday"), value: Day.Wednesday),
    DropdownMenuItem(child: Text("Thursday"), value: Day.Thursday),
    DropdownMenuItem(child: Text("Friday"), value: Day.Friday),
    DropdownMenuItem(child: Text("Saturday"), value: Day.Saturday),
    DropdownMenuItem(child: Text("Sunday"), value: Day.Sunday),
  ];

  Future onNotificationSelected(String payload) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future initializeNotifications() async {
    var androidInitialize = new AndroidInitializationSettings('app_icon');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings =
        new InitializationSettings(androidInitialize, iOSInitialize);
    localNotifications = new FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings,
        onSelectNotification: onNotificationSelected);
  }

  Future<void> _scheduleNotification(
      String title, String body, int seconds) async {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(
      seconds: seconds,
    ));
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('1',
        'scheduled', 'Scheduled notifications are sent through this channel',
        //icon: 'secondary_icon',
        sound: RawResourceAndroidNotificationSound('scheduled'),
        //largeIcon: DrawableResourceAndroidBitmap('sample_large_icon'),
        ongoing: true,
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'scheduled');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotifications.schedule(0, title, body,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  Future<void> _showDailyAtTime(
      String title, String body, int hour, int minute, int second) async {
    var time = Time(hour, minute, second);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1',
        'Daily Scheduled Notifications',
        'Daily scheduled notifications are shown here');

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotifications.showDailyAtTime(
        0, title, body, time, platformChannelSpecifics);
  }

  Future<void> _showWeeklyAtDayAndTime(
      String title, String body, int hour, int minute, Day day) async {
    var time = Time(hour, minute, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '2',
        'Weekly Scheduled Notifications',
        'Weekly shceduled notifications are sent through this channel');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotifications.showWeeklyAtDayAndTime(
        0, title, body, day, time, platformChannelSpecifics);
  }

  Future<void> _checkPendingNotificationRequests() async {
    var pendingNotificationRequests =
        await localNotifications.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
              '${pendingNotificationRequests.length} pending notification requests'),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0',
      'Miscellaneous',
      'One Time Notifications are sent through this time',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      autoCancel: false,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await localNotifications.show(0, title, body, platformChannelSpecifics,
        payload: 'item x');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Notifications()));
  }

  TimeOfDay time;
  Day pickedDay;

  Future<TimeOfDay> showTime() async {
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) {
      setState(() {
        time = t;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    time = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Send push notifications"),
          backgroundColor: Colors.deepPurple[300]),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Text(" Notify your customers\n with push notifications",
                      style: TextStyle(color: Colors.black54, fontSize: 20)),
                  Icon(Icons.notifications_active,
                      color: Colors.deepPurple[200], size: 45),
                ],
              ),

              // One Time Notifications
              Container(
                width: double.infinity,
                height: 200,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "One Time Notifications",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      //Title Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: title1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Body Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: body1,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Body",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            focusColor: Colors.grey,
                            enableFeedback: true,
                            icon: Icon(Icons.notifications_active,
                                color: Colors.deepPurple[300], size: 40),
                            onPressed: () async {
                              await initializeNotifications();
                              _showNotification(title1.text, body1.text);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                            }),
                      ),
                    ],
                  ),
                ),
              ),

              //Scheduled Notifications
              Container(
                width: double.infinity,
                height: 280,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "One Time Schedule",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      //Title Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: title2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Body Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: body2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Body",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      FlatButton(
                        child: Text("Select Time",
                            style: TextStyle(color: Colors.blue)),
                        onPressed: showTime,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timer),
                          SizedBox(width: 10),
                          time == null
                              ? Text("Selected Time: None")
                              : Text("Selected Time: " +
                                  time.hour.toString() +
                                  ":" +
                                  time.minute.toString()),
                        ],
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            focusColor: Colors.grey,
                            enableFeedback: true,
                            icon: Icon(Icons.notifications_active,
                                color: Colors.deepPurple[300], size: 40),
                            onPressed: () async {
                              await initializeNotifications();
                              _scheduleNotification(title2.text, body2.text,
                                  (time.hour * 3600 + time.minute * 60));
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Notifications()));
                            }),
                      ),
                    ],
                  ),
                ),
              ),

              //Daily Schedule
              Container(
                width: double.infinity,
                height: 280,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "Daily Schedule",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      //Title Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: title3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Body Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: body3,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Body",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),

                      FlatButton(
                        child: Text("Select Time",
                            style: TextStyle(color: Colors.blue)),
                        onPressed: showTime,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timer),
                          SizedBox(width: 10),
                          time == null
                              ? Text("Selected Time: None")
                              : Text("Selected Time: " +
                                  time.hour.toString() +
                                  ":" +
                                  time.minute.toString()),
                        ],
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            focusColor: Colors.grey,
                            enableFeedback: true,
                            icon: Icon(Icons.notifications_active,
                                color: Colors.deepPurple[300], size: 40),
                            onPressed: () async {
                              await initializeNotifications();
                              _showDailyAtTime(title3.text, body3.text,
                                  time.hour, time.minute, 0);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Notifications()));
                            }),
                      ),
                    ],
                  ),
                ),
              ),

              //Weekly Schedule
              Container(
                width: double.infinity,
                height: 310,
                margin: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.grey),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "Weekly Schedule",
                        style: TextStyle(color: Colors.black54, fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      //Title Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: title4,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Body Field
                      Container(
                        width: 250,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.black38),
                            left: BorderSide(color: Colors.black38),
                            right: BorderSide(color: Colors.black38),
                            top: BorderSide(color: Colors.black38),
                          ),
                        ),
                        child: TextField(
                          controller: body4,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 15, right: 15, bottom: 10),
                            hintText: "Body",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 5),
                          Text("Select Day",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 17)),
                          SizedBox(width: 30),
                          DropdownButton(
                              value: pickedDay,
                              hint: Text("Day"),
                              items: days,
                              onChanged: (val) {
                                setState(() {
                                  pickedDay = val;
                                });
                              }),
                        ],
                      ),
                      FlatButton(
                        child: Text("Select Time",
                            style: TextStyle(color: Colors.blue)),
                        onPressed: showTime,
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timer),
                          SizedBox(width: 10),
                          time == null
                              ? Text("Selected Time: None")
                              : Text("Selected Time: " +
                                  time.hour.toString() +
                                  ":" +
                                  time.minute.toString()),
                        ],
                      ),
                      SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            focusColor: Colors.grey,
                            enableFeedback: true,
                            icon: Icon(Icons.notifications_active,
                                color: Colors.deepPurple[300], size: 40),
                            onPressed: () async {
                              await initializeNotifications();
                              _showWeeklyAtDayAndTime(title4.text, body4.text,
                                  time.hour, time.minute, pickedDay);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Notifications()));
                            }),
                      ),
                    ],
                  ),
                ),
              ),

              //Pending notifications
              Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Check pending notifications"),
                  onPressed: () async {
                    await initializeNotifications();
                    _checkPendingNotificationRequests();
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Text("Cancelling Notifications",
                      style: TextStyle(color: Colors.black54, fontSize: 18)),
                  SizedBox(width: 10),
                  Icon(Icons.notifications_off, size: 40),
                ],
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Cancel One Time Notifications"),
                  onPressed: () async {
                    await initializeNotifications();
                    await localNotifications.cancel(0);
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Cancel Daily Notifications"),
                  onPressed: () async {
                    await initializeNotifications();
                    await localNotifications.cancel(1);
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Cancel Weekly Notifications"),
                  onPressed: () async {
                    await initializeNotifications();
                    await localNotifications.cancel(2);
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text("Cancel All Notifications"),
                  onPressed: () async {
                    await initializeNotifications();
                    await localNotifications.cancelAll();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
