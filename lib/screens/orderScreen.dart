import 'package:cached_network_image/cached_network_image.dart';
import 'package:charity/screens/mapPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;
  final String email;

  const OrderScreen(
      {Key key,
      this.imageUrl,
      this.title,
      this.description,
      this.price,
      this.email})
      : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                      width: double.infinity,
                      //color: Colors.orange,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.fill,
                      )),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: Text(
                            widget.description,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        // Quantity Selector
                        SizedBox(height: 30),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  name: widget.title,
                                  price: widget.price,
                                  quantity: quantity.toString(),
                                  imageUrl: widget.imageUrl,
                                  email: widget.email,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[300],
                            ),
                            child: Center(
                              child: Text(
                                "Choose your Location",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.moneyBillWave,
                            color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "GH¢" + widget.price,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ), //Icon(Icons.fastfood, color: Colors.white),
                height: 70,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
