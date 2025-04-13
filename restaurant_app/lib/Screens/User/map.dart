import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> allMarkers = [];
  // Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _controller;
  late Position _currentPosition;
  Map<MarkerId, Marker> markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _requestLocationPermission();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _addMarker(
            LatLng(_currentPosition.latitude, _currentPosition.longitude),
            "origin",
            BitmapDescriptor.defaultMarker);
      });
      print("Current Location: $_currentPosition");
    } catch (e) {
      print('Error: $e');
    }
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  // Future<void> _loadMarkers() async {
  //   await Future.forEach(_restaurantsList.restaurantsList,
  //       (Restaurant res) async {
  //     final marker = await getMarker(res);
  //     setState(() {
  //       allMarkers.add(marker);
  //     });
  //   });
  // }
  @override
  void dispose() {
    _controller.dispose(); // Dispose of the GoogleMapController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      //   // title: Text(
      //   //   'Maps Explorer',
      //   //   style: Theme.of(context)
      //   //       .textTheme
      //   //       .titleLarge!
      //   //       .merge(TextStyle(letterSpacing: 1.3)),
      //   // ),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.my_location),
      //       onPressed: _goToMyLocation,
      //     ),
      //   ],
      // ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              alignment: AlignmentDirectional.bottomStart,
              children: <Widget>[
                Positioned(
                  top: 0,
                  right: 10.w,
                  child: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: _goToMyLocation,
                  ),
                ),
                _currentPosition != null
                    ? GoogleMap(
                        mapType: MapType.terrain,
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition.latitude,
                              _currentPosition.longitude),
                          zoom: 15.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        markers: Set<Marker>.of(markers.values),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final PermissionStatus status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
              'This app needs to access your location to show nearby restaurants. Please grant access.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _goToMyLocation() async {
    if (_currentPosition != null && _controller != null) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // Future<Marker> getMarker(Restaurant res) async {
  //   final Uint8List markerIcon = await getBytesFromAsset('img/marker.png', 120);
  //   final Marker marker = Marker(
  //     markerId: MarkerId(res.id),
  //     icon: BitmapDescriptor.fromBytes(markerIcon),
  //     onTap: () {
  //       print(res.name);
  //     },
  //     position: LatLng(res.lat, res.lon),
  //   );

  //   return marker;
  // }
}
