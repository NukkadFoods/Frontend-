import 'dart:developer';

import 'package:driver_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controller/orders/orders_model.dart';

class MapProvider extends ChangeNotifier {
  MapProvider({
    required this.userPosition,
    required this.orderData,
    required this.restaurant,
  });
  final LatLng userPosition;
  final OrderData orderData;
  final Restaurant restaurant;
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polyCoordinates = [];

  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Loaction is permanently denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  void addMarkers() async {
    log(userPosition.toString());
    BitmapDescriptor restaurantIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(22, 22)), 'assets/images/nukkadMap.png');
    markers.add(Marker(
        markerId: MarkerId('restaurant'),
        icon: restaurantIcon,
        position: LatLng(restaurant.latitude!, restaurant.longitude!)));
    restaurantIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(22, 22)), 'assets/images/userMap.png');
    log('Users location' + restaurant.latitude.toString());
    markers.add(Marker(
        markerId: MarkerId('user'),
        icon: restaurantIcon,
        position: userPosition));
    // notifyListeners();

    ////
    PolylinePoints polyPoints = PolylinePoints();
    try {
      if (polylines.containsKey(PolylineId('line'))) {
        log('skipped api calling');
      } else {
        log('calling maps api');
        polylines.clear();
        PolylineResult result = await polyPoints.getRouteBetweenCoordinates(
            googleApiKey: "AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw",
            request: PolylineRequest(
                origin:
                    PointLatLng(restaurant.latitude!, restaurant.longitude!),
                destination:
                    PointLatLng(userPosition.latitude, userPosition.longitude),
                mode: TravelMode.driving));
        if (result.points.isNotEmpty) {
          result.points.forEach((PointLatLng point) {
            polyCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        }
        PolylineId id = PolylineId('line');
        polylines[id] = Polyline(
            endCap: Cap.roundCap,
            width: 5,
            polylineId: id,
            color: colorBrightGreen,
            points: polyCoordinates);
      }
    } catch (e) {
      log(e.toString());
    }

    //
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(restaurant.latitude!, restaurant.longitude!),
        zoom: 14)));
    notifyListeners();
  }

  @override
  void dispose() {
    mapController.dispose();
    markers.clear();
    polyCoordinates.clear();
    polylines.clear();
    super.dispose();
  }
}
