import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/screens/authentication_screens/work_preference_screen.dart';
import 'package:driver_app/screens/location_screens/location_screen.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/common/transition_to_next_screen.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../location_broadcast.dart';

class OrderController {
  static late Stream<DocumentSnapshot<Map<String, dynamic>>> orderStream;
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static String? phoneNumber;
  static LocationBroadcast location = LocationBroadcast();
  static late DocumentReference<Map<String, dynamic>> streamRef;

  // void getPhoneNumber() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   phoneNumber = prefs.getString('contact_number');
  // }

  static void setStatus() {
    if (phoneNumber != null) {
      db.collection('dboys').doc(phoneNumber).update({'status': true});
    }
  }

  static Future<void> getStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phoneNumber = prefs.getString('contact_number');
    streamRef = db.collection('dboys').doc(phoneNumber);
    if (phoneNumber != null) {
      orderStream = streamRef.snapshots();
    } else {
      throw Exception('no contact number found');
    }
    await location.getPermissions();
  }

  static void acceptOrder(OrderData orderData) async {
    streamRef
        .update({'orders.${orderData.orderId}.accepted': true}).onError((e, _) {
      log(e.toString());
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    db
        .collection('tracking')
        .doc(orderData.orderId)
        .update({'dBoyId': prefs.getString('uid')!});
    location.updateOrderId(orderData.orderId!);
    location.initialize();
    DutyController.endDuty();
  }

  static void declineOrder(OrderData orderData) async {
    streamRef.update({'orders.${orderData.orderId}.accepted': false}).onError(
        (e, _) {
      log(e.toString());
    });
  }

  static Future<bool> acceptUnassignedOrder(OrderData orderData) async {
    final result = await db.runTransaction((transaction) async {
      final Map orders =
          (await transaction.get(db.collection('hubs').doc(orderData.hubId!)))
                  .data()!['unassigned'] ??
              {};
      if (orders[orderData.orderId] == null) {
        //show error dialog
        return false;
      } else {
        transaction.update(db.collection('hubs').doc(orderData.hubId!),
            {'unassigned.${orderData.orderId!}': FieldValue.delete()});
        return true;
      }
    });

    if (result == false) {
      return false;
    }

    orderData.accepted = true;
    db.runTransaction((transaction) async {
      transaction.update(db.collection('dboys').doc(phoneNumber),
          {'isBusy': true, 'orders.${orderData.orderId}': orderData.toJson()});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      transaction.update(db.collection('tracking').doc(orderData.orderId!),
          {'dBoyId': prefs.getString('uid')!});
    });
    location.updateOrderId(orderData.orderId!);
    location.initialize();
    DutyController.endDuty();
    return true;
  }

  // static void declineUnassignedOrder(OrderData orderData) async {
  //   final orders = await streamRef.get();
  //   for (var order in orders.get('orders')) {
  //     if (order['orderId'] == orderData.orderId) {
  //       streamRef.update({
  //         'orders': FieldValue.arrayRemove([order])
  //       }).onError((e, _) {
  //         log(e.toString());
  //       });
  //       break;
  //     }
  //   }
  //   orderData.accepted = false;
  //   db.collection('dboys').doc(phoneNumber).update({
  //     'isBusy': true,
  //     'orders': FieldValue.arrayUnion([orderData.toJson()])
  //   }).onError((e, _) {
  //     log(e.toString());
  //   });
  // }

  static Future<bool> orderDelivered(OrderData orderData) async {
    await db.runTransaction((transaction) async {
      transaction.update(db.collection('dboys').doc(phoneNumber),
          {"orders.${orderData.orderId}": FieldValue.delete()});
    });

    final orders =
        (await db.collection('dboys').doc(phoneNumber).get()).get('orders');

    final result = orders[orderData.orderId!] == null;

    if (result) {
      location.stop();
    }
    return result;
  }
}

class DutyController {
  static String homeHub = '';
  static String currentHub = '';
  static Map queueBody = {};
  static final db = FirebaseFirestore.instance;
  static bool isOnDuty = false;
  static late Map deliveryBoyData;
  static List myHubs = [];
  static bool inValidRange = false;
  static late Map hubsMetadata;
  static late Position position;
  static bool gettingHubs = false;

  static void init(Map data, BuildContext context) async {
    deliveryBoyData = data;
    hubsMetadata = (await db.collection('hubs').doc('metadata').get()).data()!;
    getHub(context);
  }

  static Future<void> getHub(BuildContext context) async {
    if (gettingHubs) {
      return;
    }
    gettingHubs = true;
    myHubs.clear();
    homeHub = deliveryBoyData['workPreference'][0]['locationName']
        .toString()
        .toLowerCase();
    String city = deliveryBoyData['city']!;
    position = await Geolocator.getCurrentPosition();
    final temp = hubsMetadata[city.toLowerCase()] ?? {};
    Map hubs = {};
    for (MapEntry e in temp.entries) {
      hubs[e.key.toString().trim()] = e.value;
    }
    if (!hubs.containsKey(homeHub)) {
      final updated = await Navigator.of(context)
          .push(transitionToNextScreen(const WorkPreferenceScreen(
        isRegistering: false,
      )));
      if (updated != null && updated!) {
        deliveryBoyData =
            jsonDecode(SharedPrefsUtil().getString('deliveryBoyData')!);
        getHub(context);
        return;
      } else {
        return;
      }
    }
    final tempHub = hubs[homeHub];
    // double? distance;

    List<MapEntry> hubIdsWithDistance = [];
    hubs.forEach((key, value) {
      final distanceFromHomeHub = Geolocator.distanceBetween(
          double.parse(tempHub['lat'].toString()),
          double.parse(tempHub['lng'].toString()),
          double.parse(value['lat'].toString()),
          double.parse(value['lng'].toString()));
      hubIdsWithDistance.add(MapEntry(key, distanceFromHomeHub));
    });
    hubIdsWithDistance.sort((a, b) => a.value.compareTo(b.value));
    for (final hub in hubIdsWithDistance) {
      final hubToBeAdded = hubs[hub.key];
      if (Geolocator.distanceBetween(
              double.parse(hubToBeAdded['lat']),
              double.parse(hubToBeAdded['lng']),
              position.latitude,
              position.longitude) <
          12000) {
        myHubs.add(hubToBeAdded);
        if (myHubs.length > 2) {
          break;
        }
      }
    }

    if (myHubs.isEmpty && context.mounted) {
      final updated = await showDialog(
          context: context, builder: (context) => selectNewCityPrompt(context));
      if (updated == true) {
        final updated = await Navigator.of(context)
            .push(transitionToNextScreen(const WorkPreferenceScreen(
          isRegistering: false,
        )));
        if (updated != null && updated!) {
          deliveryBoyData =
              jsonDecode(SharedPrefsUtil().getString('deliveryBoyData')!);
          getHub(context);
          return;
        }
      }
    }
    gettingHubs = false;
  }

  static Future<void> startDuty(BuildContext context) async {
    if (myHubs.isEmpty) {
      await getHub(context);
    }
    String contact = deliveryBoyData['contact'];
    bool? takeHome;
    position = await Geolocator.getCurrentPosition();
    queueBody['lat'] = position.latitude;
    queueBody['lng'] = position.longitude;
    queueBody['uid'] = SharedPrefsUtil().getString('uid')!;
    queueBody['hubId'] =
        currentHub; //replace currentHub with homehub to enable take home feature
    // if (currentHub != homeHub) {
    //   takeHome = await showDialog(
    //     context: context,
    //     builder: (context) => takeHomeSelector(context),
    //   );
    // }
    queueBody['takeHome'] = takeHome ?? false;
    queueBody['id'] = contact;
    queueBody['waitingFrom'] = DateTime.now().toIso8601String();

    for (Map hub in myHubs) {
      db.runTransaction((transaction) async {
        List queue =
            (await transaction.get(db.collection('hubs').doc(hub['hubId'])))
                .data()!['queue'];
        queue = queue.reversed.toList();
        for (int i = 0; i < queue.length; i++) {
          if (queue[i]['id'] == contact) {
            return;
          }
        }
        await transaction.update(db.collection('hubs').doc(hub['hubId']), {
          'queue': FieldValue.arrayUnion([queueBody])
        });
      }).then((_) {}, onError: (e) {
        print(e);
      });
    }
  }

  static void endDuty() async {
    isOnDuty = false;
    String contact = deliveryBoyData['contact'];
    Map queueBody = {};
    for (Map hub in myHubs) {
      db.runTransaction((transaction) async {
        List queue =
            (await transaction.get(db.collection('hubs').doc(hub['hubId'])))
                .data()!['queue'];
        queue = queue.reversed.toList();
        // print(queue[0]);
        for (int i = 0; i < queue.length; i++) {
          if (queue[i]['id'] == contact) {
            queueBody = queue[i];
            break;
          }
        }
        transaction.update(db.collection('hubs').doc(hub['hubId']), {
          'queue': FieldValue.arrayRemove([queueBody])
        });
      });
    }
  }

  static Widget selectNewCityPrompt(BuildContext context) {
    return AlertDialog.adaptive(
      content: Text(
          'You are more than 12 Km away from your selected Work city and area.\nPlease update your work preferences according to your current location'),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
            onPressed: () async {
              final updated = await Navigator.of(context)
                  .push(transitionToNextScreen(const LocationScreen(
                isRegistering: false,
              )));
              if (updated != null && updated!) {
                deliveryBoyData =
                    jsonDecode(SharedPrefsUtil().getString('deliveryBoyData')!);
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: colorGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text("Ok")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text("Cancel")),
      ],
    );
  }

  static Widget takeHomeSelector(BuildContext context) {
    return AlertDialog.adaptive(
      content: Text(
          'You are not in your Base Hub.\nDo you want to enable Takehome to receive order which takes you nearer to your Base hub?'),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: colorGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text("Yes")),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text("No")),
      ],
    );
  }
}
