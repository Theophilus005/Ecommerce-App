import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddFood extends StatefulWidget {
  final String category;

  const AddFood({Key key, this.category}) : super(key: key);

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  //Text Field Variables
  String title;
  String price;
  String description;
  File uploadedImage;
  bool loading;
  final _formKey = GlobalKey<FormState>();

  // Get Image from Gallery
  Future getImageGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      uploadedImage = File(pickedFile.path);
    });
  }

  //Get Image from Camera
  Future getImageCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      uploadedImage = File(pickedFile.path);
    });
  }

  // Adds the data to firebase
  Future addData(String url, docName) async {
    await Firestore.instance
        .collection(widget.category)
        .document(docName)
        .setData({
      'title': title.substring(0, 1).toUpperCase() + title.substring(1),
      'price': price,
      'decription': description,
      'imageUrl': url,
      'oldDoc': docName
    });
  }

  Future search(String url, docName) async {
    await Firestore.instance.collection("Search").document(docName).setData({
      'title': title.substring(0, 1).toUpperCase() + title.substring(1),
      'price': price,
      'description': description,
      'imageUrl': url,
      'searchKey': title.substring(0, 1).toUpperCase()
    });
  }

  // Uploads Image to firebase Storage
  Future uploadImage(String name) async {
    final StorageReference reference = FirebaseStorage().ref().child(name);
    final StorageUploadTask uploadTask = reference.putFile(uploadedImage);
    await uploadTask.onComplete;
    final link = await reference.getDownloadURL();
    print(link);
    return link;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter the details"),
        backgroundColor: Colors.deepPurple[400],
      ),
      body: Builder(
        builder: (context) => loading == true
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),

                      // Title Field
                      Center(
                        child: Container(
                          width: 260,
                          child: TextFormField(
                            validator: (val) =>
                                val.isEmpty ? 'This field is required' : null,
                            onChanged: (val) {
                              setState(() {
                                title = val;
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
                              ),
                              labelText: "Title",
                              labelStyle: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      //Price Field
                      Center(
                        child: Container(
                          width: 260,
                          child: TextFormField(
                            validator: (val) =>
                                val.isEmpty || val.contains(RegExp(r'[A-Z]'))
                                    ? 'Provide a valid price'
                                    : null,
                            onChanged: (val) {
                              setState(() {
                                price = val;
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple[400]),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple[500]),
                              ),
                              labelText: "Price",
                              labelStyle: TextStyle(color: Colors.black38),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Image Upload Field
                      Container(
                        child: Column(
                          children: <Widget>[
                            // Upload Image Text
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Upload Product Image",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),

                            // Subtitle Text
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "This is the image buyers will see",
                                  style: TextStyle(
                                      color: Colors.black38, fontSize: 13),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Image Preview Container
                            Container(
                              width: 260,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: uploadedImage == null
                                  ? Center(
                                      child: Text(
                                        "No Image Selected",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 16),
                                      ),
                                    )
                                  : Image.file(uploadedImage, fit: BoxFit.fill),
                            ),

                            // Camera and Gallery Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.camera_alt, size: 40),
                                  onPressed: getImageCamera,
                                ),
                                SizedBox(width: 100),
                                IconButton(
                                  icon: Icon(Icons.image, size: 40),
                                  onPressed: getImageGallery,
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            //Description Title
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Say something about this product"),
                              ),
                            ),
                            SizedBox(height: 10),

                            //Description TextField
                            Center(
                              child: Container(
                                width: 260,
                                child: TextFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      description = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.deepPurple),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.deepPurple),
                                    ),
                                    labelText: "Description",
                                    labelStyle:
                                        TextStyle(color: Colors.black38),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Sell Text
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Make product available to buyers"),
                              ),
                            ),
                            SizedBox(height: 10),

                            //Sell Button
                            GestureDetector(
                              onTap: () async {
                                try {
                                  if (_formKey.currentState.validate() &&
                                      uploadedImage != null &&
                                      title != null &&
                                      description != null &&
                                      price != null) {
                                    setState(() {
                                      loading = true;
                                    });

                                    final link = await uploadImage(title);
                                    if (link != null) {
                                      setState(() {
                                        loading = false;
                                      });
                                      addData(link, title);
                                      search(link, title);

                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Successfully added"),
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print(e.toString());
                                }
                              },
                              child: Container(
                                width: 260,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "SELL",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
