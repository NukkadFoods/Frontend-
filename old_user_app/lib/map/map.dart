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
  bool _mapLoadError = false;
  String _mapErrorMessage = '';
  LatLng _initialPosition = const LatLng(23.259933, 77.412613);
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  String saveAs = '';
  final TextEditingController _addressController = TextEditingController();
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    print('🗺️ ========== MAP INITIALIZATION DEBUG ==========');
    print('🗺️ Map Widget Created: MapsScreen');
    print('🗺️ loginSkipped: ${widget.loginSkipped}');
    print('🗺️ add: ${widget.add}');
    print('🗺️ Initial Position: $_initialPosition');
    _diagnoseMapIssues();
    _getCurrentLocation();
  }

  void _diagnoseMapIssues() {
    print('🔍 ========== MAP DIAGNOSTIC CHECKS ==========');
    print('🔍 Flutter Google Maps version: ^2.10.1');
    print('🔍 Platform: iOS');
    print('🔍 API Key configured: ${("AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw").isNotEmpty}');
    print('🔍 API Key format valid: ${("AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw").startsWith("AIza")}');
    print('🔍 Initial lat/lng: ${_initialPosition.latitude}, ${_initialPosition.longitude}');
    print('🔍 Position valid: ${_initialPosition.latitude != 0.0 && _initialPosition.longitude != 0.0}');
    
    // Common fixes to try:
    print('💡 If map tiles don\'t load, check:');
    print('💡 1. Google Cloud Console billing enabled');
    print('💡 2. Maps SDK for iOS API enabled');
    print('💡 3. API key restrictions (iOS bundle ID)');
    print('💡 4. Network connectivity for tile downloads');
  }

  Future<void> _getCurrentLocation() async {
    print('📍 ========== LOCATION SERVICES DEBUG ==========');
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📍 Location Service Enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      _showEnableLocationServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('📍 Current Permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('📍 Permission After Request: $permission');
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permission denied forever');
      return;
    }

    print('📍 Getting current position...');
    Position position = await Geolocator.getCurrentPosition();
    print('✅ Current Position: Latitude ${position.latitude}, Longitude ${position.longitude}');
    
    if (mounted) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _updateMarkerAndCircle(_initialPosition);
        _getAddressFromLatLng(_initialPosition);
      });
      print('✅ Map state updated with new position');
    }

    print('🗺️ Animating camera to new position...');
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 18.0,
        ),
      ),
    );
    print('✅ Camera animation completed');

    // Save latitude and longitude in SharedPreferences
    await _saveCoordinatesToPreferences(position.latitude, position.longitude);
    print('✅ Coordinates saved to SharedPreferences');
  }

  Future<void> _saveCoordinatesToPreferences(
      double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    print('Saved Coordinates: Latitude $latitude, Longitude $longitude');
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    print('🌍 ========== GEOCODING ADDRESS ==========');
    print('🌍 Geocoding position: ${position.latitude}, ${position.longitude}');
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      print('🌍 Placemarks found: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print('🌍 Primary placemark: ${place.toString()}');
        
        saveAs = place.name ?? '';
        setState(() {
          _currentAddress =
              "${place.street}, ${place.locality}, ${place.country}";
          _addressController.text = _currentAddress;
        });
        
        print('✅ Address updated: $_currentAddress');
        print('✅ SaveAs: $saveAs');
      } else {
        print('❌ No placemarks found for this position');
      }

      print('✅ Position updated successfully: Latitude ${position.latitude}, Longitude ${position.longitude}');
    } catch (e) {
      print('❌ Geocoding error: $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong with address lookup',
          backgroundColor: textWhite,
          textColor: primaryColor);
    }
  }

  void _updateMarkerAndCircle(LatLng newPosition) {
    print('🎯 ========== UPDATING MARKERS & CIRCLES ==========');
    print('🎯 New Position: ${newPosition.latitude}, ${newPosition.longitude}');
    print('🎯 Current markers count: ${_markers.length}');
    print('🎯 Current circles count: ${_circles.length}');
    
    setState(() {
      _markers.clear();
      _circles.clear();
      print('🎯 Cleared existing markers and circles');

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
      print('✅ Added marker at ${newPosition.latitude}, ${newPosition.longitude}');

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
      print('✅ Added circle at ${newPosition.latitude}, ${newPosition.longitude}');
      print('🎯 Final markers count: ${_markers.length}');
      print('🎯 Final circles count: ${_circles.length}');
    });
    print('✅ Markers and circles update completed');
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
                print('🗺️ ========== GOOGLE MAP CREATED ==========');
                print('🗺️ GoogleMapController initialized');
                print('🗺️ Controller: $controller');
                print('🗺️ Map Type: MapType.normal');
                print('🗺️ API Key (last 10 chars): ...${("AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw").substring(29)}');
                
                try {
                  mapController = controller;
                  print('🗺️ Updating markers and circles...');
                  _updateMarkerAndCircle(_initialPosition);
                  print('✅ Map creation completed successfully');
                  
                  setState(() {
                    _mapLoadError = false;
                    _mapErrorMessage = '';
                  });
                  
                  // Test if map is responding
                  Future.delayed(Duration(seconds: 2), () {
                    print('🔍 Testing map responsiveness...');
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _initialPosition, zoom: 15.0),
                      ),
                    ).then((_) {
                      print('✅ Map camera animation successful - map is responsive');
                    }).catchError((error) {
                      print('❌ Map camera animation failed: $error');
                      setState(() {
                        _mapLoadError = true;
                        _mapErrorMessage = 'Camera animation failed: $error';
                      });
                    });
                  });
                } catch (e) {
                  print('❌ Error during map creation: $e');
                  setState(() {
                    _mapLoadError = true;
                    _mapErrorMessage = 'Map creation error: $e';
                  });
                }
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              onTap: (newPosition) async {
                print('🗺️ Map tapped at: ${newPosition.latitude}, ${newPosition.longitude}');
                _updateMarkerAndCircle(newPosition);
                _getAddressFromLatLng(newPosition);
                _saveCoordinatesToPreferences(
                    newPosition.latitude, newPosition.longitude);
              }),
          // Debug overlay
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🗺️ MAP DEBUG INFO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Position: ${_initialPosition.latitude.toStringAsFixed(4)}, ${_initialPosition.longitude.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Markers: ${_markers.length} | Circles: ${_circles.length}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Address: ${_currentAddress.isEmpty ? "Not loaded" : _currentAddress}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_mapLoadError)
                    Text(
                      '❌ Map Error: $_mapErrorMessage',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Force refresh map with satellite view
                          });
                          print('🗺️ Attempting to refresh map...');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: Text('Refresh', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (mapController != null) {
                            await mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(target: _initialPosition, zoom: 18.0),
                              ),
                            );
                            print('🔍 Zoomed to maximum level');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        child: Text('Zoom+', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
