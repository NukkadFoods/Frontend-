import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'dart:convert';

import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';

class RouteMapWidget extends StatefulWidget {
  const RouteMapWidget({super.key});

  @override
  _RouteMapWidgetState createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  late GoogleMapController mapController;
  LatLng _origin = const LatLng(23.259933, 77.412613); // Replace with your origin
  LatLng _destination = const LatLng(13.0826802, 80.2707184); // Default destination
  bool _isLoading = true; // Add a loading flag
  UserModel? user;
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getRestaurantLocation();
  }

  void getUserInfo() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);

    userResult.fold((String text) {}, (UserModel userModel) {
      setState(() {
        user = userModel;
        var userLat = userModel.user!.addresses![0].latitude;
        var userLong = userModel.user!.addresses![0].longitude;

        if (userLat != null && userLong != null) {
          _destination = LatLng(userLat.toDouble(), userLong.toDouble());
        } else {
          _destination = const LatLng(13.0826802, 80.2707184); // Default location
        }

        _drawRoute(); // Recalculate route when destination changes
      });
    });
  }

  Future<void> getRestaurantLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? resLatitude = prefs.getDouble('restaurant_latitude');
    double? resLongitude = prefs.getDouble('restaurant_longitude');

    setState(() {
      if (resLatitude != null && resLongitude != null) {
        _origin = LatLng(resLatitude, resLongitude);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.0, // Set your desired height
      width: double.infinity, // Use 100% of available width
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _origin,
              zoom: 6,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _zoomToFit();
            },
            markers: {
              Marker(markerId: const MarkerId('origin'), position: _origin),
              Marker(markerId: const MarkerId('destination'), position: _destination),
            },
            polylines: _polylines,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _drawRoute() async {
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
        _isLoading = false;
      });
      _zoomToFit(); // Adjust camera after route is drawn
    } else {
      setState(() {
        _isLoading = false; // Route failed to load
      });
    }
  }

  Future<Map<String, dynamic>?> _getRoute() async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&key=AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'] as List;

      if (routes.isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];

        return {
          'route': _decodePolyline(points),
        };
      }
    } else {
      print('Error fetching directions: ${response.body}');
    }
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

  // Adjust camera zoom to fit both origin and destination
  void _zoomToFit() {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _origin.latitude < _destination.latitude ? _origin.latitude : _destination.latitude,
        _origin.longitude < _destination.longitude ? _origin.longitude : _destination.longitude,
      ),
      northeast: LatLng(
        _origin.latitude > _destination.latitude ? _origin.latitude : _destination.latitude,
        _origin.longitude > _destination.longitude ? _origin.longitude : _destination.longitude,
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
