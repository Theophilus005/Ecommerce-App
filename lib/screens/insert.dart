import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity/screens/addfood.dart';
import 'package:charity/screens/admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'mealModel.dart';

class Meals extends StatefulWidget {
  final String category;

  Meals({this.category});

  @override
  _MealsState createState() => _MealsState();
}

List<MealModel> meals;

final _formKey = GlobalKey<FormState>();

class _MealsState extends State<Meals> {
  File uploadedImage;
  final title = new TextEditingController();
  final _price = new TextEditingController();
  final description = new TextEditingController();
  bool loading = false;

  // Get Meal from firebase
  Future getMeals() async {
    try {
      Firestore.instance
          .collection(widget.category)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          meals = snapshot.documents
              .map((documents) => MealModel.fromFirebase(documents.data))
              .toList();
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //Upload to firebase storage and get download link
  Future uploadImage(String name) async {
    final StorageReference reference = FirebaseStorage().ref().child(name);
    final StorageUploadTask uploadTask = reference.putFile(uploadedImage);
    await uploadTask.onComplete;
    final link = await reference.getDownloadURL();
    print(link);
    return link;
  }

  //update data on firebase
  Future updateData(String oldDoc, String link) async {
    await Firestore.instance
        .collection(widget.category)
        .document(oldDoc)
        .updateData({
      'title': title.text,
      'price': _price.text,
      'decription': description.text,
      'imageUrl': link,
      'OldDocName': oldDoc
    });
  }

  Future updateSearch(String oldDoc, String link) async {
    await Firestore.instance.collection("Search").document(oldDoc).updateData({
      'title': title.text,
      'price': _price.text,
      'description': description.text,
      'imageUrl': link,
      'OldDocName': oldDoc
    });
  }

  // Deletes an item from the category
  Future delete(String name) async {
    await Firestore.instance
        .collection(widget.category)
        .document(name)
        .delete();
  }

  Future deleteSearch(String name) async {
    await Firestore.instance.collection("Search").document(name).delete();
  }

  //Updates the category number
  Future updateNumber() async {
    await Firestore.instance
        .collection('Categories')
        .document(widget.category)
        .updateData({'Number': FieldValue.increment(-1)});
  }

  @override
  void initState() {
    getMeals();
    super.initState();
  }

  //Get Image from Camera
  Future getImageCamera() async {
    final temp = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      uploadedImage = File(temp.path);
    });
  }

//Get Image from Gallery
  Future getImageGallery() async {
    final temp = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      uploadedImage = File(temp.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add or Edit Products",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primary,
      ),
      body: meals.isEmpty
          ? Center(
              child: Text("There are no products in this category",
                  style: TextStyle(color: Colors.black38, fontSize: 17)))
          : Builder(
              builder: (context) => loading == true
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Products",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 20),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          meals != null
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: meals.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: MealTile(
                                        image: CachedNetworkImage(
                                          imageUrl: meals[index].imageUrl,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                        price: meals[index].price,
                                        title: meals[index].title,
                                        delete: () async {
                                          Navigator.pop(context);
                                          await FirebaseStorage()
                                              .ref()
                                              .child(meals[index].oldDoc)
                                              .delete();
                                          delete(meals[index].oldDoc);
                                          deleteSearch(meals[index].oldDoc);
                                          updateNumber();
                                        },
                                        edit: () {
                                          Scaffold.of(context)
                                              .showBottomSheet((context) =>
                                                  Container(
                                                      color: Colors.white,
                                                      height: 300,
                                                      width: double.infinity,
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Form(
                                                                key: _formKey,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: <
                                                                      Widget>[
                                                                    SizedBox(
                                                                        height:
                                                                            20),

                                                                    //Title Text Field
                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            260,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              title,
                                                                          validator: (val) => val.isEmpty
                                                                              ? "This field is required"
                                                                              : null,
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[300],
                                                                                ),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[400],
                                                                                ),
                                                                              ),
                                                                              labelText: "Title",
                                                                              labelStyle: TextStyle(color: Colors.black38)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),

                                                                    // Price Form Field
                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            260,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _price,
                                                                          validator: (val) => val.isEmpty
                                                                              ? "Provide a valid price"
                                                                              : null,
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[300],
                                                                                ),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[400],
                                                                                ),
                                                                              ),
                                                                              labelText: "Price",
                                                                              labelStyle: TextStyle(color: Colors.black38)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),

                                                                    // Description form Field

                                                                    Center(
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            260,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              description,
                                                                          decoration: InputDecoration(
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[300],
                                                                                ),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: Colors.deepPurple[400],
                                                                                ),
                                                                              ),
                                                                              labelText: "Description(optional)",
                                                                              labelStyle: TextStyle(color: Colors.black38)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),

                                                                    // Upload Image Field
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              30),
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child: Text(
                                                                            "Update Image",
                                                                            style:
                                                                                TextStyle(color: Colors.black38, fontSize: 18)),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        IconButton(
                                                                          icon: Icon(
                                                                              Icons.camera_alt,
                                                                              size: 40),
                                                                          onPressed:
                                                                              getImageCamera,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                30),
                                                                        IconButton(
                                                                          icon: Icon(
                                                                              Icons.image,
                                                                              size: 40),
                                                                          onPressed:
                                                                              getImageGallery,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    Text(
                                                                      "There will be no preview",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black38),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    // update button
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.pop(
                                                                            context);

                                                                        final link =
                                                                            await uploadImage(meals[index].title);
                                                                        if (link !=
                                                                            null) {
                                                                          await updateData(
                                                                              meals[index].oldDoc,
                                                                              link);
                                                                          updateSearch(
                                                                              meals[index].oldDoc,
                                                                              link);
                                                                          setState(
                                                                              () {
                                                                            loading =
                                                                                false;
                                                                          });
                                                                        }
                                                                        Scaffold.of(context).showSnackBar(SnackBar(
                                                                            content:
                                                                                Text("Update Successfull")));
                                                                      },
                                                                      child: Container(
                                                                          width: 260,
                                                                          height: 40,
                                                                          child: Center(
                                                                            child:
                                                                                Text(
                                                                              "UPDATE",
                                                                              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.orange[400],
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          )),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),

                                                                    //Cancel button
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: Container(
                                                                          width: 260,
                                                                          height: 40,
                                                                          child: Center(
                                                                            child:
                                                                                Text(
                                                                              "CANCEL",
                                                                              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.red[400],
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          )),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                  ],
                                                                )),
                                                          ],
                                                        ),
                                                      )));
                                        },
                                      ),
                                    );
                                  },
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Loading, please wait..."),
                                    CircularProgressIndicator(),
                                  ],
                                ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple[300],
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFood(category: widget.category),
            ),
          );
        },
      ),
    );
  }
}

class MealTile extends StatelessWidget {
  const MealTile(
      {Key key,
      this.image,
      this.price,
      this.title,
      this.info,
      this.delete,
      this.edit})
      : super(key: key);

  final Widget image;
  final String price;
  final String title;
  final String info;
  final Function delete;
  final Function edit;

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Title: ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    "Price: ",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    price,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              GestureDetector(
                onTap: edit,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                "Edit",
                                style: TextStyle(color: primary, fontSize: 20),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primary, size: 20),
                              onPressed: edit,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white, size: 30),
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
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
