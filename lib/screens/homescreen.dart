import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity/screens/Review.dart';
import 'package:charity/screens/about.dart';
import 'package:charity/screens/favourites.dart';
import 'package:charity/screens/login.dart';
import 'package:charity/screens/myOrders.dart';
import 'package:charity/screens/orderModel.dart';
import 'package:charity/screens/recentOrders.dart';
import 'package:charity/screens/reviewModel.dart';
import 'package:charity/screens/settings.dart';
import 'package:charity/screens/spinkit.dart';
import 'package:charity/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin.dart';
import 'categoryModel.dart';
import 'mealModel.dart';
import 'orderScreen.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({Key key, this.email}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final AuthService _auth = AuthService();
final searchController = new TextEditingController();
String admin = '';
bool flag = false;

class _HomeScreenState extends State<HomeScreen> {
  List<CategoryModel> doc;
  List<MealModel> items;
  Map firstCategory;
  int initial = 1;
  Color active = Colors.orange;
  Color notActive = Colors.black;
  bool isClicked = false;
  String selected = 'Loading';
  List<RecentModel> orders;
  List<ReviewModel> reviews;
  List firstQueryResults = [];
  List secondQueryResults = [];

  //Initiate Search function
  searchByName<QuerySnapshot>(String searchField) async {
    return await Firestore.instance
        .collection("Search")
        .where("searchKey",
            isEqualTo: searchField.substring(0, 1).toUpperCase())
        .getDocuments();
  }

  initiateSearch(String value) async {
    if (value.length == 0) {
      setState(() {
        firstQueryResults = [];
        secondQueryResults = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (firstQueryResults.length == 0 && value.length == 1) {
      Firestore.instance
          .collection("Search")
          .where("searchKey", isEqualTo: value.substring(0, 1).toUpperCase())
          .getDocuments()
          .then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          setState(() {
            firstQueryResults.add(docs.documents[i].data);
          });
          print(capitalizedValue);
        }
      });
    } else {
      secondQueryResults = [];
      firstQueryResults.forEach((element) {
        if (element['title'].startsWith(capitalizedValue)) {
          setState(() {
            secondQueryResults.add(element);
            print(capitalizedValue);
          });
        }
      });
    }
  }

  share(String title, String text, String url) {}

  //Get Categories from Firebase
  Future getCategory() async {
    return Firestore.instance
        .collection("Categories")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        doc = snapshot.documents
            .map((document) => CategoryModel.fromFirestore(document.data))
            .toList();
      });
    });
  }

  Future getItemsfromCategory(String name) async {
    return Firestore.instance.collection(name).snapshots().listen((snapshot) {
      setState(() {
        items = snapshot.documents
            .map((document) => MealModel.fromFirebase(document.data))
            .toList();
      });
    });
  }

  Future addToFavourite(String uid, String name, String price, String imageUrl,
      String description, String id) async {
    Firestore.instance
        .collection("User Orders")
        .document(uid)
        .collection("Favourites")
        .document(id)
        .setData({
      'order': name,
      'imageUrl': imageUrl,
      'price': price,
      'id': id,
      'description': description
    });
  }

  Future getAllOrders() async {
    Firestore.instance
        .collection("All orders")
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        orders = snapshot.documents
            .map((documents) => RecentModel.fromFirestore(documents.data))
            .toList();
      });
    });
  }

  getLatestReviews() {
    Firestore.instance
        .collection("Reviews")
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        reviews = snapshot.documents
            .map((documents) => ReviewModel.fromFirestore(documents.data))
            .toList();
      });
    });
  }

  @override
  void initState() {
    getCategory();
    Timer.periodic(Duration(seconds: 1), (t) {
      if (doc != null) {
        setState(() {
          if (initial > 0) {
            initial--;
            print(initial);
          }
          if (initial == 0) {
            getItemsfromCategory(doc[0].category);
            setState(() {
              selected = doc[0].category;
            });
            t.cancel();
          }
        });
      }
    });
    getAllOrders();
    getLatestReviews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        //leading: IconButton(
        //icon:Icon(Icons.menu, size:35),
        //onPressed: () {}
        //),
        backgroundColor: Colors.deepPurple[300],
        elevation: 0.0,
        actions: <Widget>[
          email == 'theophilito@gmail.com' ||
                  user.email == 'theophilito@gmail.com' ||
                  user.email == 'admin@gmail.com' ||
                  email == 'admin@gmail.com'
              ? IconButton(
                  icon: Icon(Icons.swap_horizontal_circle, size: 47),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminPanel(),
                      ),
                    );
                  },
                )
              : Container(),
          SizedBox(width: 20),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Favourites(uid: user.uid)));
                },
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),

      // drawer
      drawer: Drawer(
        child: SafeArea(
          child: Container(
            color: Colors.deepPurple[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(height: 50),

                // My Orders Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyOrders(uid: user.uid)));
                  },
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 10),
                        Icon(Icons.fastfood, color: Colors.white, size: 30),
                        SizedBox(width: 8),
                        Text(
                          "My Orders",
                          style: TextStyle(color: Colors.white, fontSize: 23),
                        ),
                      ],
                    ),
                  ),
                ),

                //Review
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Review(uid: user.uid, email: user.email)));
                  },
                  child: Container(
                      child: Row(children: <Widget>[
                    SizedBox(width: 10),
                    FaIcon(FontAwesomeIcons.bookOpen,
                        color: Colors.white, size: 25),
                    SizedBox(width: 8),
                    Text(
                      "Review Us",
                      style: TextStyle(color: Colors.white, fontSize: 23),
                    ),
                  ])),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AboutUs()));
                  },
                  child: Container(
                      child: Row(children: <Widget>[
                    SizedBox(width: 10),
                    Icon(Icons.history, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      "About Us",
                      style: TextStyle(color: Colors.white, fontSize: 23),
                    ),
                  ])),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Settings(email: user.email, uid: user.uid)));
                  },
                  child: Container(
                      child: Row(children: <Widget>[
                    SizedBox(width: 10),
                    Icon(Icons.settings, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      "Account",
                      style: TextStyle(color: Colors.white, fontSize: 23),
                    ),
                  ])),
                ),

                //LogOut Button
                GestureDetector(
                  onTap: () async {
                    await _auth.signOut();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Login(isLoggedOut: true)));
                  },
                  child: Container(
                      child: Row(children: <Widget>[
                    SizedBox(width: 10),
                    Icon(Icons.person, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      "logout",
                      style: TextStyle(color: Colors.white, fontSize: 23),
                    ),
                  ])),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
      body: doc == null || items == null
          ? Loading()
          : Builder(
              builder: (context) => SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[300],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "We've got the best \nproducts for you",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Fast Delivery Service you can trust",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6),
                          TextField(
                            controller: searchController,
                            onChanged: (value) async {
                              await initiateSearch(value);
                              print(firstQueryResults.length);
                              print(secondQueryResults.length);
                            },
                            decoration: InputDecoration(
                              hintText: "Search...",
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                            ),
                          )
                        ],
                      ),
                    ),
                    // ** Render flex error solved
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: doc.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    getItemsfromCategory(doc[index].ref);
                                    setState(() {
                                      selected = doc[index].ref;
                                    });
                                    /* if (isClicked == false) {
                                        setState(() {
                                          isClicked = true;
                                        });
                                      }*/
                                  },
                                  child: Categories(
                                      category: doc[index].category,
                                      color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 15),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: searchController.text.length == 0
                                ? Text(
                                    selected,
                                    style: TextStyle(
                                        fontSize: 23, color: Colors.black54),
                                  )
                                : firstQueryResults.isEmpty
                                    ? Text("No match found")
                                    : firstQueryResults.isNotEmpty
                                        ? Text("Showing Results for" +
                                            " " +
                                            firstQueryResults.length
                                                .toString() +
                                            " matche(s)")
                                        : secondQueryResults.isNotEmpty
                                            ? Text("Showing Results for" +
                                                " " +
                                                secondQueryResults.length
                                                    .toString() +
                                                " matche(s)")
                                            : Text(
                                                selected,
                                                style: TextStyle(
                                                    fontSize: 23,
                                                    color: Colors.black54),
                                              )),
                      ],
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                              height: 200,
                              child: items == null
                                  ? Center(child: CircularProgressIndicator())
                                  : items.isEmpty
                                      ? Center(
                                          child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.announcement,
                                                color: Colors.black45,
                                                size: 40),
                                            SizedBox(height: 10),
                                            Text(
                                                "No items yet in this category",
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontSize: 17)),
                                          ],
                                        ))
                                      : searchController.text.length == 1 ||
                                              firstQueryResults.isNotEmpty ||
                                              secondQueryResults.isNotEmpty
                                          ?
                                          //Displays items from search
                                          ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: searchController
                                                          .text.length ==
                                                      1
                                                  ? firstQueryResults.length
                                                  : secondQueryResults.length,
                                              itemBuilder: (context, index) {
                                                return firstQueryResults.isEmpty
                                                    ? Text("No match found")
                                                    : Featured(
                                                        name: searchController.text.length == 1
                                                            ? firstQueryResults[index]
                                                                ['title']
                                                            : secondQueryResults[index]
                                                                ['title'],
                                                        share:
                                                            searchController
                                                                        .text
                                                                        .length ==
                                                                    1
                                                                ? () {
                                                                    FlutterShare.share(
                                                                        title: firstQueryResults[index]
                                                                            [
                                                                            'title'],
                                                                        text: firstQueryResults[index]
                                                                            [
                                                                            'description'],
                                                                        linkUrl:
                                                                            "https://firebasestorage.googleapis.com/v0/b/food-delivery-app-c9996.appspot.com/o/logo%2Flogo.png?alt=media&token=03f47f78-8da3-44e0-94c9-2b8adce370e5",
                                                                        chooserTitle:
                                                                            'Fast Delivery Services');
                                                                  }
                                                                : () {
                                                                    FlutterShare.share(
                                                                        title: secondQueryResults[index]
                                                                            [
                                                                            'title'],
                                                                        text: secondQueryResults[index]
                                                                            [
                                                                            'description'],
                                                                        linkUrl:
                                                                            "https://firebasestorage.googleapis.com/v0/b/food-delivery-app-c9996.appspot.com/o/logo%2Flogo.png?alt=media&token=03f47f78-8da3-44e0-94c9-2b8adce370e5",
                                                                        chooserTitle:
                                                                            'Fast Delivery Services');
                                                                  },
                                                        image: searchController.text.length == 1
                                                            ? firstQueryResults[index]
                                                                ['imageUrl']
                                                            : secondQueryResults[index]
                                                                ['imageUrl'],
                                                        price: double.parse(searchController.text.length == 1 ? firstQueryResults[index]['price'] : secondQueryResults[index]['price'])
                                                            .toStringAsFixed(2),
                                                        favourite: () async {
                                                          await addToFavourite(
                                                            user.uid,
                                                            searchController
                                                                        .text
                                                                        .length ==
                                                                    1
                                                                ? firstQueryResults[
                                                                        index]
                                                                    ['title']
                                                                : secondQueryResults[
                                                                        index]
                                                                    ['title'],
                                                            searchController
                                                                        .text
                                                                        .length ==
                                                                    1
                                                                ? firstQueryResults[
                                                                        index]
                                                                    ['price']
                                                                : secondQueryResults[
                                                                        index]
                                                                    ['price'],
                                                            searchController
                                                                        .text
                                                                        .length ==
                                                                    1
                                                                ? firstQueryResults[
                                                                        index]
                                                                    ['imageUrl']
                                                                : secondQueryResults[
                                                                        index][
                                                                    'imageUrl'],
                                                            searchController
                                                                        .text
                                                                        .length ==
                                                                    1
                                                                ? firstQueryResults[
                                                                        index][
                                                                    'description']
                                                                : secondQueryResults[
                                                                        index][
                                                                    'description'],
                                                            Random()
                                                                .nextInt(5000)
                                                                .toString(),
                                                          );
                                                          Scaffold.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  "Added To Favourites"),
                                                              duration:
                                                                  Duration(
                                                                seconds: 4,
                                                              ),
                                                            ),
                                                          );
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Favourites(
                                                                          uid: user
                                                                              .uid)));
                                                        },
                                                        description: searchController
                                                                    .text
                                                                    .length ==
                                                                1
                                                            ? firstQueryResults[index]
                                                                ['description']
                                                            : secondQueryResults[index]
                                                                ['description'],
                                                        goToOrders: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          OrderScreen(
                                                                            title: searchController.text.length == 1
                                                                                ? firstQueryResults[index]['title']
                                                                                : secondQueryResults[index]['title'],
                                                                            imageUrl: searchController.text.length == 1
                                                                                ? firstQueryResults[index]['imageUrl']
                                                                                : secondQueryResults[index]['imageUrl'],
                                                                            price: searchController.text.length == 1
                                                                                ? firstQueryResults[index]['price']
                                                                                : secondQueryResults[index]['price'],
                                                                            description: searchController.text.length == 1
                                                                                ? firstQueryResults[index]['description']
                                                                                : secondQueryResults[index]['description'],
                                                                            email:
                                                                                user.email,
                                                                          )));
                                                        });
                                              })
                                          :

                                          //Display Items from Category
                                          ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: items.length,
                                              itemBuilder: (context, index) {
                                                return Featured(
                                                    name: items[index].title,
                                                    image:
                                                        items[index].imageUrl,
                                                    share: () {
                                                      FlutterShare.share(
                                                          title: items[index]
                                                              .title,
                                                          text: items[index]
                                                              .description,
                                                          linkUrl:
                                                              "https://firebasestorage.googleapis.com/v0/b/food-delivery-app-c9996.appspot.com/o/logo%2Flogo.png?alt=media&token=03f47f78-8da3-44e0-94c9-2b8adce370e5",
                                                          chooserTitle:
                                                              'Fast Delivery Services');
                                                    },
                                                    price: double.parse(
                                                            items[index].price)
                                                        .toStringAsFixed(2),
                                                    favourite: () async {
                                                      await addToFavourite(
                                                          user.uid,
                                                          items[index].title,
                                                          items[index].price,
                                                          items[index].imageUrl,
                                                          items[index]
                                                              .description,
                                                          Random()
                                                              .nextInt(5000)
                                                              .toString());
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              "Added To Favourites"),
                                                          duration: Duration(
                                                            seconds: 4,
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Favourites(
                                                                      uid: user
                                                                          .uid)));
                                                    },
                                                    description: items[index]
                                                        .description,
                                                    goToOrders: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      OrderScreen(
                                                                        title: items[index]
                                                                            .title,
                                                                        imageUrl:
                                                                            items[index].imageUrl,
                                                                        price: items[index]
                                                                            .price,
                                                                        description:
                                                                            items[index].description,
                                                                        email: user
                                                                            .email,
                                                                      )));
                                                    });
                                              })),
                        ),
                      ],
                    ),
                    /*SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      
                      Featured(
                          name: "Rice & Beans",
                          image: "assets/images/rice_beans.jpg",
                          price: 15.00),
                      Featured(
                          name: "Pizza",
                          image: "assets/images/pizza_1.jpg",
                          price: 20.00),
                    ],
                  ),
                ),*/
                    SizedBox(
                      height: 5,
                    ),
                    orders.isEmpty || orders == null
                        ? Container()
                        : Row(
                            children: <Widget>[
                              SizedBox(width: 15),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Recent Orders",
                                    style: TextStyle(
                                        fontSize: 23, color: Colors.black54),
                                  )),
                            ],
                          ),
                    SizedBox(height: 10),

                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: orders.length < 3 ? orders.length : 3,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MostPopular(
                          name: orders[index].order,
                          price: orders[index].totalprice.toStringAsFixed(2),
                          image: orders[index].imageUrl,
                        );
                      },
                    ),

                    /*MostPopular(
                                  name: "Rice & Chicken",
                                  image: "assets/images/rice_and_chicken.png",
                                  orders: "42 orders",
                                  price: "30.00"), */

                    SizedBox(height: 12),

                    //Reviews Section
                    reviews == null || reviews.isEmpty
                        ? Container()
                        : Container(
                            child: Column(
                              children: <Widget>[
                                //Review Title
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Reviews",
                                      style: TextStyle(
                                          fontSize: 23, color: Colors.black54),
                                    ),
                                  ),
                                ),

                                // Reviews subtitle
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "See what our customers are saying",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black54),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),

                                //Review Tiles
                                ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        reviews.length < 5 ? reviews.length : 5,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ReviewTile(
                                        name: reviews[index].name,
                                        message: reviews[index].message,
                                        date: reviews[index].date,
                                      );
                                    }),
                                SizedBox(height: 30),
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

class ReviewTile extends StatelessWidget {
  final String name;
  final String message;
  final String date;

  const ReviewTile({Key key, this.name, this.message, this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey)],
      ),
      child: Column(children: <Widget>[
        SizedBox(height: 6),
        Row(
          children: <Widget>[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset("assets/images/logo.png"),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: TextStyle(color: Colors.black54))
              ],
            ),
          ],
        ),
        //SizedBox(height: ),

        // Review Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  margin: EdgeInsets.only(left: 15),
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.deepPurple[100],
                        width: 5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(message, style: TextStyle(fontSize: 16)),
                  )),
            ),
          ),
        ),
      ]),
    );
  }
}

class MostPopular extends StatelessWidget {
  const MostPopular({Key key, this.name, this.price, this.image})
      : super(key: key);

  final String name;
  final String price;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 12),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
          color: Colors.deepPurple[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 3, color: Colors.deepPurple[100])]),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Center(
              child: Container(
                width: 140,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    "GH¢$price",
                    style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Featured extends StatelessWidget {
  const Featured(
      {Key key,
      this.name,
      this.price,
      this.image,
      this.goToOrders,
      this.description,
      this.favourite,
      this.share})
      : super(key: key);

  final String name;
  final String price;
  final String image;
  final Function goToOrders;
  final String description;
  final Function favourite;
  final Function share;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: goToOrders,
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 12),
            height: 180,
            width: 180,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)]),
          ),

          //Image section
          Positioned(
            left: 12,
            child: Container(
              width: 180,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.fill,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                  child: CircularProgressIndicator(
                      value: downloadProgress.progress),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),

          //Title Section
          Positioned(
            top: 130,
            left: 20,
            child: Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 17),
              softWrap: true,
              maxLines: 1,
            ),
          ),
          //Title Section
          Positioned(
            top: 153,
            left: 20,
            child: Text(
              "GH¢" + price,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),

          //Share Icon
          Positioned(
            top: 140,
            left: 100,
            child: IconButton(
              icon: Icon(Icons.share, color: Colors.black),
              onPressed: share,
            ),
          ),

          //Favorite Icon
          Positioned(
            top: 140,
            left: 140,
            child: IconButton(
              icon: Icon(Icons.favorite, color: Colors.red),
              onPressed: favourite,
            ),
          )
        ],
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories({Key key, this.category, this.color}) : super(key: key);

  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.deepPurple[300],
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(blurRadius: 2, color: Colors.deepPurple[100])
            ]),
        margin: EdgeInsets.all(10),
        child: Center(
          child: Row(
            children: <Widget>[
              SizedBox(width: 5),
              Text(
                category,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
        ));
  }
}
