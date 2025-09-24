import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'dart:convert';
import 'package:user_app/widgets/constants/strings.dart';

class Liveordertracking extends StatefulWidget {
  const Liveordertracking({
    super.key,
    required this.orderid,
    required this.nukkad,
    required this.onEstimatedTimeCalculated,
    required this.db,
    required this.isDelivery, // Add callback here
  });

  final String orderid;
  final Restaurants nukkad;
  final Function(int) onEstimatedTimeCalculated; // Define the callback type
  final Stream<DocumentSnapshot<Map<String, dynamic>>> db;
  final bool isDelivery;

  @override
  _LiveordertrackingState createState() => _LiveordertrackingState();
}

class _LiveordertrackingState extends State<Liveordertracking> {
  GoogleMapController? mapController;
  LatLng? _userLocation;
  LatLng? _driverLocation;
  bool _isLoading = true;
  bool _isPolylineDrawn = false;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  late AssetMapBitmap riderIcon;
  UserModel? user;
  // Stream<DocumentSnapshot<Map<String, dynamic>>>? db;
  @override
  void initState() {
    super.initState();
    // db = FirebaseFirestore.instance
    //     .collection('tracking') // Replace with your Firestore collection path
    //     .doc(widget.orderid) // Replace with relevant orderId
    //     .snapshots();
    getMapDetails();
  }

  void getMapDetails() async {
    final data = await FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.orderid)
        .get();
    _userLocation = LatLng(data.data()!['userLat'], data.data()!['userLng']);
    if (data.data()!['lat'] != 0 && data.data()!['lng'] != 0) {
      _driverLocation = LatLng(data.data()!['lat'], data.data()!['lng']);
    } else {
      _driverLocation = LatLng(widget.nukkad.latitude!.toDouble(),
          widget.nukkad.longitude!.toDouble());
    }
    mapController?.animateCamera(CameraUpdate.newLatLng(_userLocation!));
    _drawRoute();
    riderIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(30, 30)),
        'assets/icons/riderMap.png');
  }

  /// Fetches and builds the Google Map with StreamBuilder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: widget.db,
        builder: (context, snapshot) {
          if (snapshot.data == null || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            if (!(data['lat'] == 0.0 || data['lng'] == 0.0)) {
              _driverLocation = LatLng(data['lat'], data['lng']);
              _updateDriverMarker(); // Update driver's marker position
            }
          }
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation!,
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _zoomToFit();
            },
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
          );
        },
      ),
    );
  }

// In _drawRoute, consider updating the map camera position again if needed
  Future<void> _drawRoute() async {
    if (_isPolylineDrawn) return;
    final routeData = await _getRoute();
    if (routeData != null) {
      final route = routeData['route'];

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: route,
            color: Colors.blue,
            width: 5,
          ),
        );
        _isPolylineDrawn = true;
        _addMarkers(); // Add initial markers
        _isLoading = false;
      });

      // Optionally update the camera position again
      mapController?.animateCamera(CameraUpdate.newLatLng(_userLocation!));
      _zoomToFit();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkers() async {
    BitmapDescriptor icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/icons/userMap.png');
    _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        icon: icon));
    icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(20, 20)),
        'assets/icons/nukkadMap.png');
    _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: LatLng(widget.nukkad.latitude!.toDouble(),
            widget.nukkad.longitude!.toDouble()),
        icon: icon));
    if (widget.isDelivery) {
      _markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation!,
          icon: riderIcon));
    }
    // if (mounted) {
    //   setState(() {});
    // }
  }

  void _updateDriverMarker() {
    if (!widget.isDelivery) {
      return;
    }
    _markers
        .removeWhere((marker) => marker.markerId == const MarkerId('driver'));
    // final icon = await BitmapDescriptor.asset(
    //     const ImageConfiguration(size: Size(30, 30)),
    //     'assets/icons/riderMap.png');
    _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation!,
        icon: riderIcon));
    // if (mounted) {
    //   setState(() {});
    // }
    _zoomToFit();
  }

  Future<Map<String, dynamic>?> _getRoute() async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?destination=${_userLocation!.latitude},${_userLocation!.longitude}&origin=${widget.nukkad.latitude},${widget.nukkad.longitude}&key=${AppStrings.GOOGLE_API_KEY}'));
      print('onmap : ${_userLocation!.latitude} ,${_userLocation!.longitude}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final routes = data['routes'] as List;
        log(data.keys.toList().toString());

        if (routes.isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final duration = data['routes'][0]['legs'][0]['duration']
              ['value']; // Duration in seconds
          // Call the callback to send estimated time in seconds to the previous screen
          widget
              .onEstimatedTimeCalculated(duration); // Pass duration in seconds

          return {
            'route': _decodePolyline(points),
            'duration': duration, // Return duration in seconds
          };
        }
      } else {
        print('Error fetching directions: ${response.body}');
      }
    } catch (e) {}
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng((lat / 1E5), (lng / 1E5)));
    }

    return polyline;
  }

  void _zoomToFit() {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _userLocation!.latitude < _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude < _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
      northeast: LatLng(
        _userLocation!.latitude > _driverLocation!.latitude
            ? _userLocation!.latitude
            : _driverLocation!.latitude,
        _userLocation!.longitude > _driverLocation!.longitude
            ? _userLocation!.longitude
            : _driverLocation!.longitude,
      ),
    );

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }
}
