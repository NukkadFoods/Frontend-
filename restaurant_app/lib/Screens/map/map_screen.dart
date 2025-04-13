import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Screens/User/documentationScreen.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:sizer/sizer.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, this.restaurantModel});
  final RestaurantModel? restaurantModel;

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(23.259933, 77.412613);
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // Set for circles

  LocalController _getSavedData = LocalController();
  final TextEditingController _addressController = TextEditingController();
  String _currentAddress = '';
  late Map<String, dynamic> userInfo;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getUserData();
  }

  Future<void> getUserData() async {
    if (widget.restaurantModel != null) {
      userInfo = widget.restaurantModel!.user!.toJson();
      return;
    }
    try {
      Map<String, dynamic>? getData = await _getSavedData.getUserInfo();
      setState(() {
        userInfo = getData!;
      });
    } catch (e) {
      print('Error: $e');
      // Handle error
    }
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(userInfo));
    print(prefs.getString('user_info'));
  }

  Future<void> _getCurrentLocation() async {
    if(widget.restaurantModel!=null){
      _initialPosition=LatLng((widget.restaurantModel!.user!.latitude??0).toDouble(), (widget.restaurantModel!.user!.longitude??0).toDouble());
      return;
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showEnableLocationServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    print(
        'Current Position: Latitude ${position.latitude}, Longitude ${position.longitude}'); // Print the latitude and longitude
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _markers.clear();
      _circles.clear(); // Clear existing circles

      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _initialPosition,
          draggable: false,
          onDragEnd: (newPosition) {
            setState(() {
              _initialPosition = newPosition;
            });
            _getAddressFromLatLng(newPosition); // Reverse geocode on drag
          },
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Add a circle to show the current location area
      _circles.add(
        Circle(
          circleId: const CircleId('currentLocationCircle'),
          center: _initialPosition,
          radius: 50, // radius in meters
          strokeColor: Colors.blue.withOpacity(0.8),
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      );

      _getAddressFromLatLng(
          _initialPosition); // Reverse geocode initial position
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 18.0, // Adjust zoom level if needed
        ),
      ),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.country}";
        _addressController.text = _currentAddress; // Update the TextField
      });

      // Print latitude and longitude when address is updated
      print(
          'Updated Position: Latitude ${position.latitude}, Longitude ${position.longitude}');

      // Assuming userInfo is initialized and saveUserInfo is defined
      userInfo['latitude'] = position.latitude;
      userInfo['longitude'] = position.longitude;

      await saveUserInfo(userInfo);
    } catch (e) {
      print(e);
      // Optionally show an error message to the user
      Fluttertoast.showToast(
          msg: 'Something went wrong !!',
          backgroundColor: textWhite,
          textColor: Colors.red);
    }
  }

  Future<void> _onGetCurrentLocationPressed() async {
    await _getCurrentLocation(); // Re-fetch current location
  }

  void _showEnableLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'Location services are disabled. Please enable them in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: const MarkerId('initialMarker'),
                        position: _initialPosition,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            _initialPosition = newPosition;
                          });
                          _getAddressFromLatLng(
                              newPosition); // Reverse geocode on drag
                        },
                        infoWindow: const InfoWindow(title: 'You are here'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    );

                    _circles.add(
                      Circle(
                        circleId: const CircleId('initialMarkerCircle'),
                        center: _initialPosition,
                        radius: 100, // radius in meters
                        strokeColor: Colors.blue.withOpacity(0.8),
                        strokeWidth: 2,
                        fillColor: Colors.blue.withOpacity(0.3),
                      ),
                    );
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12.0,
                ),
                markers: _markers,
                circles: _circles, // Add circles to the map
                myLocationEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                rotateGesturesEnabled: true,
                onTap: (newPosition) {
                  _markers.clear();
                  _circles.clear();
                  _initialPosition = newPosition;
                  _markers.add(Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: _initialPosition));
                  _circles.add(
                    Circle(
                      circleId: const CircleId('currentLocationCircle'),
                      center: _initialPosition,
                      radius: 50, // radius in meters
                      strokeColor: Colors.blue.withOpacity(0.8),
                      strokeWidth: 2,
                      fillColor: Colors.blue.withOpacity(0.3),
                    ),
                  );
                  _getAddressFromLatLng(_initialPosition);
                  setState(() {});
                }),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.35,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 5,
                      width: 50,
                      color: const Color(0xFFCCCCCC),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      child: Center(
                          child: Text('Long press the marker to move',
                              style: TextStyle(color: Colors.red))),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter Address',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: _onGetCurrentLocationPressed,
                            color: const Color(0xFFFF4C00),
                            tooltip: 'Get Current Location',
                          ),
                          SizedBox(
                            width: 3.w,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    mainButton(
                      'Save',
                      textWhite,
                      () {
                        if (widget.restaurantModel != null) {
                          Navigator.of(context).pop(_initialPosition);
                          return;
                        }
                        saveUserInfo(userInfo);
                        Navigator.push(
                          context,
                          transitionToNextScreen(
                            const DocumentationScreen(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
