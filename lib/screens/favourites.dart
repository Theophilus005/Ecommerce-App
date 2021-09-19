import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity/screens/FavouriteModel.dart';
import 'package:charity/screens/orderScreen.dart';
import 'package:charity/screens/spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Favourites extends StatefulWidget {
  final String uid;

  const Favourites({Key key, this.uid}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<Favourite> favourites;

  Future getFavourites() async {
    Firestore.instance
        .collection("User Orders")
        .document(widget.uid)
        .collection("Favourites")
        .snapshots()
        .listen((snapshot) {
      setState(() {
        favourites = snapshot.documents
            .map((document) => Favourite.fromFirestore(document.data))
            .toList();
      });
    });
  }

  Future delete(String id) async {
    await Firestore.instance
        .collection("User Orders")
        .document(widget.uid)
        .collection("Favourites")
        .document(id)
        .delete();
  }

  @override
  void initState() {
    // TODO: implement initState
    getFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Favourites"),
          backgroundColor: Colors.deepPurple[300],
        ),
        body: favourites == null
            ? Loading()
            : favourites.isEmpty
                ? Center(
                    child: Text("No favourites have been added",
                        style: TextStyle(color: Colors.black38, fontSize: 18)))
                : ListView.builder(
                    itemCount: favourites.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return FavouritesTile(
                          title: favourites[index].title,
                          price: favourites[index].price,
                          imageUrl: favourites[index].imageUrl,
                          delete: () async {
                            await delete(favourites[index].id);
                          },
                          order: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderScreen(
                                        description:
                                            favourites[index].description,
                                        imageUrl: favourites[index].imageUrl,
                                        price: favourites[index].price,
                                        title: favourites[index].title)));
                          });
                    })

        /*lumn(
        children: <Widget>[
          FavouritesTile(),
          RaisedButton(
            child: Text("check"),
            onPressed: () async {
              await getFavourites();
              print(favourites[0].imageUrl);
            },
          ),
        ],
      ),*/
        );
  }
}

class FavouriteModel {}

class FavouritesTile extends StatelessWidget {
  final String title;
  final String price;
  final String uid;
  final String imageUrl;
  final String description;
  final Function order;
  final Function delete;

  const FavouritesTile(
      {Key key,
      this.title,
      this.price,
      this.uid,
      this.imageUrl,
      this.description,
      this.order,
      this.delete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey)],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(title,
                        style: TextStyle(color: Colors.black54, fontSize: 18)),
                    Text("GH¢ " + double.parse(price).toStringAsFixed(2),
                        style: TextStyle(color: Colors.black54, fontSize: 18)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 20),
                        RaisedButton(
                          color: Colors.deepPurple[300],
                          child: Text("Order",
                              style: TextStyle(color: Colors.white)),
                          onPressed: order,
                        ),
                        SizedBox(width: 10),
                        IconButton(
                            icon: Icon(Icons.remove_circle,
                                color: Colors.red, size: 30),
                            onPressed: delete)
                      ],
                    ),
                  ],
                ),
              ]),
        ));
  }
}
