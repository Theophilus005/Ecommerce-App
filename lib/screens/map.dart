import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController _controller;
  Position currentLocation;
  List<Marker> markers = [];
  final search = new TextEditingController();

// From a query
  geocode() async {
    final query = "Accra";
    var addresses = await Geocoder.google("").findAddressesFromQuery(query);
    var first = addresses.first;
    print("${first.featureName} : ${first.coordinates}");
  }

  Future getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = position;
      print(currentLocation.latitude);
      print(currentLocation.longitude);
    });
  }

  onMapCreated(controller) {
    setState(() {
      _controller = controller;
    });
    moveToCurrentPosition();
    addMarker();
  }

  addMarker() async {
    markers.add(
      Marker(
        markerId: MarkerId("Current Location"),
        draggable: false,
        visible: true,
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(
          title: "Location",
          snippet: "Your Current Location",
        ),
      ),
    );
  }

  moveToCurrentPosition() async {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 20,
          tilt: 30,
        ),
      ),
    );
    //addMarker();
  }

  searchLocation() {
    Geolocator().placemarkFromAddress(search.text).then(
          (locations) => () {
            _controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(locations[0].position.latitude,
                      locations[0].position.longitude),
                ),
              ),
            );
          },
        );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

//5.650,  -0.1962 UG
//5.5866, -0.2773 Awoshie
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Your Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange[400],
      ),
      body: currentLocation == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 15),
                Text("Fetching Your Location",
                    style: TextStyle(fontSize: 18, color: Colors.black54)),
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    // markers: Set.from(markers),
                    onMapCreated: onMapCreated,
                    mapType: MapType.hybrid,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(5.6037168, -0.1869644),
                      zoom: 19,
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 15,
                    right: 15,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: search,
                        enableInteractiveSelection: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search Location...",
                            contentPadding:
                                EdgeInsets.only(left: 15, right: 15, top: 15),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              iconSize: 30,
                              onPressed: searchLocation,
                            )),
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text("geocode"),
                    onPressed: geocode,
                  ),
                ],
              ),
            ),
    );
  }
}
