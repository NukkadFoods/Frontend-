import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(
      {super.key,
      required this.initialPosition,
      required this.polyLine,
      required this.markers});
  final LatLng initialPosition;
  final Set<Polyline> polyLine;
  final Set<Marker> markers;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.navigation_outlined),
      ),
      body: Container(
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: widget.initialPosition, zoom: 14),
          myLocationButtonEnabled: true,
          polylines: widget.polyLine,
        ),
      ),
    );
  }
}
