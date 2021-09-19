import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class AdminMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String deliveryPoint;

  const AdminMap({Key key, this.latitude, this.longitude, this.deliveryPoint})
      : super(key: key);

  @override
  _AdminMapState createState() => _AdminMapState();
}

class _AdminMapState extends State<AdminMap> {
  List<Marker> markers = [];
  double adminLatitude;
  double adminLongitude;
  String announcement;
  String distance;
  Color playbutton = Colors.white;
  bool mapType = true;

  var apiKey = "5b3ce3597851110001cf6248c4a0b5d6ed234725a0d9453aa4ef4fc4";
  Location location = new Location();

  FlutterTts flutterTts = FlutterTts();

  placeMarker() async {
    if (adminLatitude != null && adminLongitude != null) {
      markers.add(Marker(
        markerId: MarkerId("Location"),
        position: LatLng(adminLatitude, adminLongitude),
        infoWindow: InfoWindow(
            title: "Your Location", snippet: "This is your location"),
        visible: true,
        draggable: false,
        onTap: () {
          _speak(
              "This should be your current Location. It might not be accurate if your internet connection is not good. Do check your internet connection to ensure you have the correct locations.");
        },
      ));
    }
  }

  Future requestRoutes() async {
    var link = "https://api.mapbox.com/directions/v5/mapbox/driving/" +
        widget.longitude.toString() +
        "," +
        widget.latitude.toString() +
        ";" +
        adminLongitude.toString() +
        "," +
        adminLatitude.toString() +
        "?steps=true&voice_instructions=true&banner_instructions=true&voice_units=imperial&waypoint_names=Home;Work&access_token=pk.eyJ1IjoidGhlb3BoaWx1czAwNSIsImEiOiJja2VtbDU5c28wcnB4MnJtcTM3OWZuNTI0In0.-8IsEvkBgiRs6-F5kf8Frg";
    var response = await http.get(link);
    var body = json.decode(response.body);
    print(body);
    setState(() {
      distance = body['routes'][0]['distance'].toString();
      announcement = body['routes'][0]['legs'][0]['steps'][0]
          ['voiceInstructions'][0]['announcement'];
    });
  }

  Future getCurrentLocation() async {
    LocationData _locationData = await location.getLocation();
    setState(() {
      adminLatitude = _locationData.latitude;
      adminLongitude = _locationData.longitude;
      print(_locationData.toString());
      print(_locationData.latitude);
      print(_locationData.longitude);
    });
    placeMarker();
  }

  GoogleMapController _controller;

  onMapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  mylocation() {
    if (adminLatitude != null && adminLongitude != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(adminLatitude, adminLongitude),
        zoom: 16,
        tilt: 45,
      )));
    }
  }

  customerLocation() {
    if (widget.latitude != null && widget.longitude != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 16,
        tilt: 45,
      )));
    }
  }

  Future _speak(String speech) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(speech);
  }

  int i = 2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers.add(Marker(
        markerId: MarkerId("Customer Location"),
        draggable: false,
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: "Customer Location",
          snippet: "This is the customer's location",
        ),
        onTap: () {
          _speak(
              "This should be the location of the customer. Zoom in to see the exact location on the map.  The accuracy depends on your internet connection. To get complete directions, click on the blue icon with the arrow below");
        }));
    getCurrentLocation();
    Timer.periodic(Duration(seconds: 1), (timer) {
      i--;
      print(i);
      if (i == 0) {
        requestRoutes();
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        backgroundColor: Colors.deepPurple[300],
        actions: <Widget>[
          announcement == null || distance == null
              ? Container()
              : IconButton(
                  icon: Icon(Icons.play_arrow, color: playbutton, size: 45),
                  onPressed: () {
                    if (announcement != null && distance != null) {
                      _speak(announcement +
                          ". This customer is " +
                          distance +
                          " metres away from your current location");
                    } else if (announcement == null && distance != null) {
                      _speak("This customer is " +
                          distance +
                          " metres away from your current location");
                    } else {
                      _speak(announcement);
                    }
                  },
                ),
          SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: onMapCreated,
            markers: Set.from(markers),
            mapType: mapType ? MapType.hybrid : MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 8,
            ),
          ),

          // GPS button
          Positioned(
            top: 400,
            left: 30,
            child: GestureDetector(
              onTap: mylocation,
              child: CircleAvatar(
                  backgroundColor:
                      mapType ? Colors.white : Colors.deepPurple[300],
                  child: Icon(Icons.gps_fixed,
                      color: mapType ? Colors.deepPurple[300] : Colors.white)),
            ),
          ),

          //Map Switch Button
          Positioned(
            top: 40,
            left: 30,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  mapType = !mapType;
                });
              },
              child: CircleAvatar(
                  backgroundColor:
                      mapType ? Colors.white : Colors.deepPurple[300],
                  child: Icon(Icons.map,
                      color: mapType ? Colors.deepPurple[300] : Colors.white)),
            ),
          ),

          // Arrow Right button
          Positioned(
              top: 400,
              left: 150,
              child: GestureDetector(
                onTap: customerLocation,
                child: CircleAvatar(
                    backgroundColor:
                        mapType ? Colors.white : Colors.deepPurple[300],
                    child: FaIcon(FontAwesomeIcons.arrowRight,
                        size: 25,
                        color:
                            mapType ? Colors.deepPurple[300] : Colors.white)),
              ))

          /*RaisedButton(
              child: Text("check"),
              onPressed: () async {
                //requestRoutes();
                //print(annoucement);
                print(distance);
                //print();
                //print(markers.length);
                //_speak();
                // print("admin");
                //  print(adminLatitude);
                // print(adminLongitude);
                // print("customer");
                //print(widget.latitude);
                //print(widget.longitude);
              })*/
        ],
      ),
    );
  }
}
