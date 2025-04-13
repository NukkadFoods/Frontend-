import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/constants/shared_preferences.dart';
import '../../Widgets/constants/strings.dart';

class TrackRiderScreen extends StatefulWidget {
  const TrackRiderScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<TrackRiderScreen> createState() => _TrackRiderScreenState();
}

class _TrackRiderScreenState extends State<TrackRiderScreen> {
  // late GoogleMapController mapController;
  // double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  // double _destLatitude = 6.849660, _destLongitude = 3.648190;
  // double _originLatitude = 26.48424, _originLongitude = 50.04551;
  // double _destLatitude = 26.46423, _destLongitude = 50.06358;
  double? userLat, userLng;
  RestaurantModel? restaurantModel;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCm4zxzOxxfs6XnSdTUgcSnkWDw-uSQ75g";
  bool _isLoading = false;
  GoogleMapController? _controller;
  // late Position _currentPosition;
  late BitmapDescriptor dboyIcon;
  MarkerId dboyMarker = MarkerId('dboy');
  var db;

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  void updateLocation(LatLng position) {
    _addMarker(position, 'dboy', dboyIcon);

    // if (mounted) {
    //   setState(() {});
    // }
  }

  void getUserLocation() async {
    db = FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.orderId)
        .snapshots()
        .listen((onData) {
      updateLocation(LatLng(onData.data()!['lat'], onData.data()!['lng']));
    });
    if (restaurantModel == null) {
      fetchRestaurantModel();
    }
    dboyIcon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(20, 20)), 'assets/icons/locpin.png');
    await FirebaseFirestore.instance
        .collection('tracking')
        .doc(widget.orderId)
        .get()
        .then((onValue) {
      userLat = onValue.data()!['userLat'];
      userLng = onValue.data()!['userLng'];
      log(userLat.toString());
    });
    _getPolyline();
    addMarkers();
  }

  Future<void> fetchRestaurantModel() async {
    print('fetchRestaurantModel() called');
    String? restaurantJson =
        SharedPrefsUtil().getString(AppStrings.restaurantModel);
    if (restaurantJson != null && restaurantJson.isNotEmpty) {
      setState(() {
        restaurantModel = RestaurantModel.fromJson(json.decode(restaurantJson));
      });
    }
  }

  void addMarkers() async {
    BitmapDescriptor icon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(20, 20)), 'assets/icons/userMap.png');
    _addMarker(LatLng(userLat!, userLng!), "end", icon);
    icon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(20, 20)), 'assets/icons/nukkadMap.png');
    _addMarker(
        LatLng(restaurantModel!.user!.latitude!.toDouble(),
            restaurantModel!.user!.longitude!.toDouble()),
        "start",
        icon);
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     // Position position = await Geolocator.getCurrentPosition(
  //     //     desiredAccuracy: LocationAccuracy.high);
  //     setState(() {
  //       // _currentPosition = position;
  //       _isLoading = false;
  //       // _addMarker(
  //       //     LatLng(_currentPosition.latitude, _currentPosition.longitude),
  //       //     "origin",
  //       //     BitmapDescriptor.defaultMarker);

  //       /// destination marker
  //       // _addMarker(
  //       //     LatLng(_currentPosition.latitude + 0.1,
  //       //         _currentPosition.longitude + 0.1),
  //       //     "destination",
  //       //     BitmapDescriptor.defaultMarkerWithHue(90));
  //       _getPolyline();
  //     });
  //     // print("Current Location: $_currentPosition");
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
    if (mounted) {
      setState(() {});
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }
  // _addPolyLine() {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //       polylineId: id, color: Colors.red, points: polylineCoordinates);

  //   setState(() {
  //     polylines[id] = polyline;
  //   });
  // }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(restaurantModel!.user!.latitude!.toDouble(),
                restaurantModel!.user!.longitude!.toDouble()),
            destination: PointLatLng(userLat!, userLng!),
            mode: TravelMode.driving),
        googleApiKey: googleAPiKey);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  // Future<void> _goToMyLocation() async {
  //   if (_controller != null) {
  //     _controller!.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //           target: LatLng(restaurantModel!.user!.latitude!.toDouble(),
  //               restaurantModel!.user!.longitude!.toDouble()),
  //           zoom: 15.0,
  //         ),
  //       ),
  //     );
  //   }
  //   _getPolyline();
  // }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    } // Dispose of the GoogleMapController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Rider', style: h4TextStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              // alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                userLat != null
                    ? GoogleMap(
                        mapType: MapType.terrain,
                        // myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              restaurantModel!.user!.latitude!.toDouble(),
                              restaurantModel!.user!.longitude!.toDouble()),
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        markers: Set<Marker>.of(markers.values),
                        tiltGesturesEnabled: true,
                        compassEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        polylines: Set<Polyline>.of(polylines.values),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
    );
  }
}
