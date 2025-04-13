import 'dart:async';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationBroadcast {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late StreamSubscription<Position> positionStream;
  String orderId = '';
  Future<void> getPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location is permanently denied');
    }
  }

  void updateOrderId(String orderId) {
    this.orderId = orderId;
  }

  Future<void> initialize() async {
    positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    )).listen((position) {
      // log(position.latitude.toString() + ' , ' + position.longitude.toString());
      if (orderId.isNotEmpty) {
        print('sending data to firebase');
        db.collection("tracking").doc(orderId).update(
          {
            'lng': position.longitude,
            'lat': position.latitude,
          },
        ).onError((e, _) {
          log('Error writing Data');
        });
        print('sent data to firebase');
      }
    });
  }

  void stop() {
    positionStream.pause();
    positionStream.cancel();
  }
}
