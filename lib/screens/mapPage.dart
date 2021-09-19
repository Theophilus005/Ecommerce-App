import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'BillingScreen.dart';

class MapScreen extends StatefulWidget {
  final String name;
  final String price;
  final String quantity;
  final String imageUrl;
  final String email;
  const MapScreen(
      {Key key,
      this.name,
      this.price,
      this.quantity,
      this.imageUrl,
      this.email})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _controller;
  List<Marker> markers = [];

  FlutterTts flutterTts = new FlutterTts();

  // Position currentLocation;
  Location location = new Location();
  double latitude;
  double longitude;
  bool maptype = true;
  final search = new TextEditingController();
  changeLocation() {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(5.5866, -0.2773), zoom: 17)));
  }

  Future getCurrentLocation() async {
    LocationData _locationData = await location.getLocation();
    setState(() {
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
      print(_locationData.toString());
      print(_locationData.latitude);
      print(_locationData.longitude);
    });
    placeMarker();
  }

  speak() async {
    await flutterTts.speak(
        "The map should automatically mark your location on the screen. If it is not, kindly check your internet connection, go back and come here to refresh the screen. You can also search and place a marker at any place on the map to be used as the delivery point");
  }

  geocode() async {
    final query = search.text;
    var response = await http.get(
        "https://us1.locationiq.com/v1/search.php?key=0e046a0ea3e9fb&format=json&q=" +
            query);

    var decoded = json.decode(response.body);
    print(decoded[0]['lat']);
    print(decoded[0]['lon']);

    double lat = double.parse(decoded[0]['lat']);
    double long = double.parse(decoded[0]['lon']);
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 15,
        ),
      ),
    );
    /* placeSearchMarker(first.countryName, first.addressLine,
        first.coordinates.latitude, first.coordinates.longitude); */
  }

  // Places Marker for User Current Location
  placeMarker() async {
    if (latitude != null && longitude != null) {
      markers.add(
        Marker(
          markerId: MarkerId("Location"),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
              title: "Customer Location", snippet: "Is this your location?"),
          visible: true,
          onTap: speak,
        ),
      );
    }
  }

  // Places Marker for search Location
  placeSearchMarker(
      String country, String address, double lat, double long) async {
    markers.add(
      Marker(
        markerId: MarkerId("Search Location"),
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: country, snippet: address),
        visible: true,
        draggable: true,
      ),
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Location"),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: latitude == null || longitude == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
                Text("Fetching your location...",
                    style: TextStyle(color: Colors.black54, fontSize: 18))
              ],
            )
          : Stack(
              children: <Widget>[
                GoogleMap(
                  onTap: (position) {
                    Marker pos = Marker(
                      markerId: MarkerId("pos"),
                      infoWindow: InfoWindow(
                        title: "Selected Location",
                      ),
                      draggable: true,
                      position: position,
                    );
                    setState(() {
                      markers.clear();
                      markers.add(pos);
                    });
                  },
                  markers: Set.from(markers),
                  onMapCreated: onMapCreated,
                  mapType: maptype ? MapType.hybrid : MapType.normal,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                        latitude,
                        longitude,
                      ),
                      zoom: 20),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  right: 15,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: search,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for custom Location...",
                          contentPadding:
                              EdgeInsets.only(left: 15, right: 15, top: 15),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            iconSize: 30,
                            onPressed: geocode,
                          )),
                    ),
                  ),
                ),
                /*         RaisedButton(
                  child: Text("Change location"),
                  onPressed: getCurrentLocation,
                )*/
                Positioned(
                  top: 100,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        maptype = !maptype;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(blurRadius: 10, color: Colors.white54)
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.map, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 35,
                  left: 15,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Bill(
                              name: widget.name,
                              price: double.parse(widget.price),
                              quantity: int.parse(widget.quantity),
                              positionLatitude: markers[0].position.latitude,
                              positionLongitude: markers[0].position.longitude,
                              imageUrl: widget.imageUrl,
                              email: widget.email,
                            ),
                          ),
                        );
                        /*
                           Firestore.instance.collection("Orders").document().setData({
                             'item' : "Item name here",
                             'price' : "Item price here",
                             'quantity' : "Item quantity here",
                             'location': "Coordinates here"
                           });
                        */
                        print(markers[0].position.latitude);
                        print(markers[0].position.longitude);
                        print(markers.length);
                      },
                      child: Container(
                          width: 220,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                              child: Row(
                            children: <Widget>[
                              SizedBox(width: 25),
                              Text("Select Location",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 17)),
                              SizedBox(width: 35),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.black, size: 30)
                            ],
                          ))),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }
}
