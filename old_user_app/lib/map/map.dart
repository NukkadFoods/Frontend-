import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/screens/homeScreen.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key, required this.loginSkipped, required this.add});
  final bool loginSkipped;
  final bool add;
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(23.259933, 77.412613);
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  String saveAs = '';
  final TextEditingController _addressController = TextEditingController();
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
        'Current Position: Latitude ${position.latitude}, Longitude ${position.longitude}');
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _updateMarkerAndCircle(_initialPosition);
        _getAddressFromLatLng(_initialPosition);
      });
    }

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 18.0,
        ),
      ),
    );

    // Save latitude and longitude in SharedPreferences
    await _saveCoordinatesToPreferences(position.latitude, position.longitude);
  }

  Future<void> _saveCoordinatesToPreferences(
      double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    print('Saved Coordinates: Latitude $latitude, Longitude $longitude');
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      saveAs = place.name ?? '';
      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.country}";
        _addressController.text = _currentAddress;
      });

      print(
          'Updated Position: Latitude ${position.latitude}, Longitude ${position.longitude}');
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: 'Something went wrong',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  void _updateMarkerAndCircle(LatLng newPosition) {
    setState(() {
      _markers.clear();
      _circles.clear();

      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: newPosition,
          // draggable: true,
          // onDragEnd: (newPosition) {
          //   _updateMarkerAndCircle(newPosition);
          //   _getAddressFromLatLng(newPosition);
          // },
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      _circles.add(
        Circle(
          circleId: const CircleId('currentLocationCircle'),
          center: newPosition,
          radius: 50,
          strokeColor: Colors.blue.withOpacity(0.8),
          strokeWidth: 2,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      );
    });
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

  void _saveLocation() async {
    final address = _addressController.text;

    // Check if the address text field is empty
    if (address.isEmpty) {
      return;
    }

    // Retrieve saved coordinates from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');

    // Check if coordinates are saved and valid
    if (latitude != null && longitude != null) {
      // Optionally, you can handle further operations with the saved location here
      if (widget.loginSkipped) {
        await prefs.setString('CurrentAddress', address);
        await prefs.setString('CurrentSaveAs', saveAs);
        await prefs.setDouble('CurrentLatitude', latitude);
        await prefs.setDouble('CurrentLongitude', longitude);
        await prefs.setBool('loginSkipped', true);
        Navigator.of(context).pushAndRemoveUntil(
            transitionToNextScreen(const HomeScreen()), (_) => false);
        return;
      }
      // if (!widget.add) {
      //   // await userSignUp(latitude, longitude);
      //   return;
      // }

      // Show a confirmation message
      Fluttertoast.showToast(
          msg: 'Location Saved please enter address manually for convineince..',
          backgroundColor: textWhite,
          textColor: colorSuccess,
          toastLength: Toast.LENGTH_LONG);

      // Navigate back to the previous screen
      Navigator.pop(context);
    } else {
      // Optionally handle the case where coordinates are not available
      Fluttertoast.showToast(
          msg: 'No location selected',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _updateMarkerAndCircle(_initialPosition);
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              onTap: (newPosition) async {
                _updateMarkerAndCircle(newPosition);
                _getAddressFromLatLng(newPosition);
                _saveCoordinatesToPreferences(
                    newPosition.latitude, newPosition.longitude);
              }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isdarkmode ? textBlack : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    "Tap on Map to set new location",
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  Row(
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
                      const SizedBox(
                          width:
                              10), // Spacing between TextField and IconButton
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _getCurrentLocation,
                        tooltip: 'Get Current Location',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  mainButton("Save Location", textWhite, _saveLocation)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
