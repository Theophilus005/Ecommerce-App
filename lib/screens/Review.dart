import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Review extends StatefulWidget {
  final String uid;
  final String email;

  const Review({Key key, this.uid, this.email}) : super(key: key);

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  var review = new TextEditingController();
  Map user;
  String name;

  Future getUserName(String uid) async {
    await Firestore.instance
        .collection("Users")
        .document(uid)
        .get()
        .then((document) => setState(() {
              user = document.data;
              name = user['fname'] + ' ' + user['lname'];
            }));
  }

  Future submitReview(String uid, String message, String date) async {
    Firestore.instance.collection("Reviews").document().setData({
      'name': name,
      'message': message,
      'uid': uid,
      'date': date,
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Leave A Review"),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: <Widget>[
              SizedBox(height: 20),
              Text(
                "Let us know how you feel about our service so we could improve",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),

              //Text Field
              Container(
                margin: EdgeInsets.only(top: 20),
                height: 150,
                width: 300,
                child: TextField(
                  controller: review,
                  minLines: 5,
                  maxLines: 5,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(top: 12, left: 10, right: 10),
                    alignLabelWithHint: false,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple[300],
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepPurple[300],
                      ),
                    ),
                  ),
                ),
              ),

              //Post Button
              Container(
                margin: EdgeInsets.only(bottom: 15),
                width: 260,
                child: RaisedButton(
                  child: Text("Submit Review",
                      style: TextStyle(color: Colors.white, fontSize: 17)),
                  color: Colors.deepPurple[300],
                  onPressed: () async {
                    if (review.text.isNotEmpty) {
                      await submitReview(
                          widget.uid, review.text, DateTime.now().toString());
                      return Alert(
                        context: context,
                        title: "Review Submitted",
                        desc: "Thank you for taking time to submit this review",
                        image: Image.asset("assets/images/greentick.png"),
                      ).show();
                    }
                  },
                ),
              ),
              Text(
                "Thank you for your feedback",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              )
            ]),
          ),
        ));
  }
}
