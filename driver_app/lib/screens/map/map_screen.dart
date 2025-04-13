// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   LatLng _initialPosition = LatLng(23.259933, 77.412613);
//   Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission;

//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled, ask the user to enable them
//       return;
//     }

//     // Check for location permissions
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Permissions are denied, show a message to the user
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are permanently denied, show a message to the user
//       return;
//     }

//     // Get the current position
//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _initialPosition = LatLng(position.latitude, position.longitude);

//       // Add a draggable marker at the current location
//       _markers.add(
//         Marker(
//           markerId: MarkerId('currentLocation'),
//           position: _initialPosition,
//           draggable: true, // Enable dragging
//           onDragEnd: (newPosition) {
//             // Update the position when the marker is dragged
//             setState(() {
//               _initialPosition = newPosition;
//             });
//           },
//           infoWindow: InfoWindow(title: 'You are here'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     });

//     // Move the camera to the current location
//     mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           target: _initialPosition,
//           zoom: 12.0,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             onMapCreated: (GoogleMapController controller) {
//               mapController = controller;
//               mapController.animateCamera(
//                 CameraUpdate.newCameraPosition(
//                   CameraPosition(
//                     target: _initialPosition,
//                     zoom: 12.0,
//                   ),
//                 ),
//               );
//             },
//             initialCameraPosition: CameraPosition(
//               target: _initialPosition,
//               zoom: 12.0,
//             ),
//             markers: _markers,
//             myLocationEnabled: true,
//             scrollGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             rotateGesturesEnabled: true,
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(10),
//                       topRight: Radius.circular(10))),
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: MediaQuery.of(context).size.height * 0.28,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Container(
//                     height: 5,
//                     width: 50,
//                     color: Color(0xFFCCCCCC),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Location',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width *
//                         0.9, // Replace with the desired size
//                     child: TextField(
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           hintText: 'Enter Address'),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //       builder: (context) =>
//                         //           const DocumentationScreen()),
//                         // );
//                       },
//                       child: Text(
//                         'Save',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFFF4C00), // Background color
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(15), // Border radius of 15
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
