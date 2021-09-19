import 'dart:io';
import 'package:cache_image/cache_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity/screens/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../categoryModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../insert.dart';

class Food extends StatefulWidget {
  @override
  _FoodState createState() => _FoodState();
}

class _FoodState extends State<Food> {
  List<CategoryModel> doc;
  bool loading = false;
  String category;
  File uploadedImage;
  Color primary = Colors.deepPurple[300];

  final editCategory = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Gets Image from gallery
  Future getImageGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      uploadedImage = File(pickedFile.path);
    });
  }

  // Gets Image from camera
  Future getImageCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      uploadedImage = File(pickedFile.path);
    });
  }

  Future query() async {}

  // Gets Download link from firebase storage
  Future getDownloadLink(String category) async {
    final StorageReference ref =
        FirebaseStorage().ref().child(category + ' ' + 'category');
    final url = await ref.getDownloadURL();
    print(url);
    return url;
  }

// Adds Category to firebase

  Future addCategory(String name) async {
    try {
      setState(() {
        loading = true;
      });
      Navigator.pop(context);

      if (uploadedImage != null) {
        final StorageReference storageReference =
            FirebaseStorage().ref().child(category + ' ' + 'category');
        final StorageUploadTask uploadTask =
            storageReference.putFile(uploadedImage);
        await uploadTask.onComplete;
        final String url = await getDownloadLink(name);
        final add = await Firestore.instance
            .collection('Categories')
            .document(name)
            .setData(
          {
            'category name': name,
            'Number': 0,
            'Orders': 0,
            'imageUrl': url,
            'ref': name
          },
        );

        return add;
      } else {
        final add = await Firestore.instance
            .collection('Categories')
            .document(name)
            .setData(
          {'category name': name, 'Number': 0, 'Orders': 0, 'ref': name},
        );

        return add;
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e.toString());
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error occured, try again...")));
      return null;
    }
  }

  // Gets the categories from firbase
  getCategory() async {
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

  @override
  void initState() {
    getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: doc == null
          ? Center(
              child: Text("Add a Category",
                  style: TextStyle(color: Colors.black54, fontSize: 18)))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(children: <Widget>[
                      Text(
                        "Categories",
                        style: TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                      Spacer(),
                      loading == true
                          ? Container(
                              margin: EdgeInsets.only(right: 15),
                              child: CircularProgressIndicator(),
                            )
                          : Container(),
                    ]),
                  ),
                  SizedBox(height: 10),
                  doc != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: doc.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Meals(
                                            category: doc[index].category)));
                                //print(doc[index].category);
                              },
                              child: AdminCategory(
                                  image: doc[index].imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: doc[index].imageUrl,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ) //Image.network(doc[index].imageUrl)
                                      : Center(child: Icon(Icons.add_a_photo)),
                                  category: doc[index].category,
                                  number: doc[index].number.toString(),
                                  orders: doc[index].orders.toString(),
                                  edit: () {
                                    Scaffold.of(context)
                                        .showBottomSheet((context) => Container(
                                            width: double.infinity,
                                            height: 300,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                children: <Widget>[
                                                  SizedBox(height: 15),
                                                  Form(
                                                    child: Center(
                                                      child: Container(
                                                        color: Colors.white,
                                                        width: 260,
                                                        child: TextFormField(
                                                            validator: (val) => val
                                                                    .isEmpty
                                                                ? "Provide a category name"
                                                                : null,
                                                            controller:
                                                                editCategory,
                                                            decoration:
                                                                InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                              .orange[
                                                                          300])),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                              .orange[
                                                                          400])),
                                                              labelText:
                                                                  "Category name",
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .black38),
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),

                                                  //Upload Image Text
                                                  SizedBox(height: 15),

                                                  // Update Button
                                                  GestureDetector(
                                                      onTap: () async {
                                                        if (editCategory.text !=
                                                            null) {
                                                          await Firestore
                                                              .instance
                                                              .collection(
                                                                  "Categories")
                                                              .document(
                                                                  doc[index]
                                                                      .ref)
                                                              .updateData({
                                                            'category name':
                                                                editCategory
                                                                    .text,
                                                            'Number': 0,
                                                            'Orders': 0,
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                        /*if (category != null) {
                                                          dynamic add =
                                                              addCategory(
                                                                  doc[index]
                                                                      .ref);
                                                          if (add == null) {
                                                            setState(() {
                                                              loading = false;
                                                              Scaffold.of(
                                                                      context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    "Error occured, try again..."),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ));
                                                            });
                                                          } else {
                                                            setState(() {
                                                              loading = false;
                                                              Scaffold.of(
                                                                      context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    "Category has been updated"),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ));
                                                            });
                                                          }
                                                        }*/
                                                      },
                                                      child: Container(
                                                        width: 260,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .orange[300]),
                                                        child: Center(
                                                            child: Text(
                                                                "UPDATE",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                      )),
                                                  SizedBox(height: 10),

                                                  // Cancel Button
                                                  GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        width: 260,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .red[300]),
                                                        child: Center(
                                                            child: Text(
                                                                "CANCEL",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        19,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                      )),
                                                  SizedBox(height: 15),
                                                ],
                                              ),
                                            )));
                                  },
                                  delete: () async {
                                    Navigator.pop(context);
                                    // Deletes a category
                                    await Firestore.instance
                                        .collection('Categories')
                                        .document(doc[index].ref)
                                        .delete();
                                  }),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Loading, please wait...."),
                              SizedBox(height: 20),
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        ),

                  //Image.network(doc[1].imageUrl)
                ],
              ),
              /*AdminCategory(
                  image: "assets/images/pizza_1.jpg",
                  category: "Pizza",
                  number: "5",
                  orders: "20"),
              AdminCategory(
                  image: "assets/images/chicken_chips.jpg",
                  category: "Rice",
                  number: "10",
                  orders: "15"), */

              //doc == null ? Text("null") : Text(doc[0].category),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          return Alert(
            context: context,
            title: "ADD A CATEGORY",
            buttons: [
              DialogButton(
                color: Colors.deepPurple[400],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 2),
                    Text("ADD",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                onPressed: () async {
                  if (category != null) {
                    dynamic add = addCategory(category);
                    if (add == null) {
                      setState(() {
                        loading = false;
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Error occured, try again..."),
                          duration: Duration(seconds: 3),
                        ));
                      });
                    } else {
                      setState(() {
                        loading = false;
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Category has been added"),
                          duration: Duration(seconds: 3),
                        ));
                      });
                    }
                  }
                },
              )
            ],
            content: loading == true
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Container(
                        width: 270,
                        child: TextField(
                            onChanged: (val) => setState(() {
                                  category = val;
                                }),
                            decoration: InputDecoration(
                                hintText: "Category name",
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple[100]),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primary),
                                ))),
                      ),
                      SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("(Optional)",
                            style:
                                TextStyle(color: Colors.black45, fontSize: 15)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Upload a category image",
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(width: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.camera_alt, size: 40),
                            onPressed: getImageCamera,
                          ),
                          SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.image, size: 40),
                            onPressed: getImageGallery,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text("There will be no preview",
                          style: TextStyle(color: Colors.black45, fontSize: 14))
                    ],
                  ),
          ).show();
        },
      ),
    );
  }
}

class AdminCategory extends StatelessWidget {
  const AdminCategory(
      {Key key,
      this.image,
      this.category,
      this.number,
      this.orders,
      this.edit,
      this.delete})
      : super(key: key);

  final Widget image;
  final String category;
  final String number;
  final String orders;
  final Function edit;
  final Function delete;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 5, right: 5, bottom: 15),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 100,
              height: 80,
              color: Colors.white,
              child: image,
            ),
            SizedBox(width: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        category,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: edit,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: EdgeInsets.only(left: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("Edit",
                                      style: TextStyle(
                                          color: primary, fontSize: 17)),
                                  SizedBox(width: 8),
                                  Icon(Icons.edit, color: primary, size: 25),
                                  SizedBox(width: 5)
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 30),
                          child: IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.white, size: 28),
                            onPressed: () {
                              Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Confirmation",
                                desc:
                                    "Are you sure you want to delete this category?",
                                buttons: [
                                  DialogButton(
                                    child: Text(
                                      "YES",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: delete,
                                    color: Color.fromRGBO(0, 179, 134, 1.0),
                                  ),
                                  DialogButton(
                                    child: Text(
                                      "NO",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    color: Colors.grey,
                                  )
                                ],
                              ).show();
                            }, //delete,
                          ),
                        ),
                      ]),
                ),
                SizedBox(height: 10),
              ],
            ),
          ],
        ));
  }
}
