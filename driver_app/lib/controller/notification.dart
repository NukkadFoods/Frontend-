import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();
  static final notifications = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static NotificationDetails orderNotificationDetails =
      const NotificationDetails(
          android: AndroidNotificationDetails('orders', 'Orders',
              channelDescription: "New orders Notifications",
              priority: Priority.max,
              importance: Importance.max),
          iOS: DarwinNotificationDetails(presentSound: true));

  static Future<void> init() async {
    getPermissions();
    initLocalNotifications();
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        showNotification(message.notification!.title ?? "",
            message.notification!.body ?? '', orderNotificationDetails,
            payload: message.data.toString());
      } else {
        if (kDebugMode) {
          print("null notification received");
        }
      }
    });
    if (Platform.isIOS) {
      addTokenOnFirebase(await messaging.getAPNSToken());
    } else {
      addTokenOnFirebase(await messaging.getToken());
    }
    messaging.onTokenRefresh.listen((token) {
      addTokenOnFirebase(token);
    });
  }

  static void initLocalNotifications() async {
    const initialSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/launcher_icon"),
        iOS: DarwinInitializationSettings());
    await notifications.initialize(
      initialSettings,
      onDidReceiveNotificationResponse: (details) async {
        // print(details.payload);
        if (kDebugMode) {
          print("details ${details.payload.toString()}");
          final m = await messaging.getInitialMessage();
          if (m != null) {
            print(" get initial ${m.data}");
          } else {
            print('null notification');
          }
        }
        // navigate(2);
      },
    );
  }

  static Future<void> showNotification(
      String title, String body, NotificationDetails notificationDetails,
      {String? payload}) async {
    notifications.show(
        Random.secure().nextInt(200), title, body, notificationDetails,
        payload: payload);
  }

  static void getPermissions() async {
    NotificationSettings settings = await messaging.requestPermission();
  }

  static void addTokenOnFirebase(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('loginKey');
    if (uid != null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
            FirebaseFirestore.instance.collection('fcmTokens').doc('driver'),
            {uid: token});
      });
    }
  }

  static Future<void> sendNotification({
    required String toUid,
    required String toApp,
    String? title,
    String? body,
    Map? data,
  }) async {
    try {
      final sendNotification =
          FirebaseFunctions.instance.httpsCallable('sendNotification');
      final result = await sendNotification.call({
        "uid": toUid,
        "toApp": toApp,
        "title": title,
        "body": body,
        "data": data ?? {},
        "channel": "orders"
      });
      if (kDebugMode) {
        print(result.data);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}


































// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:restaurant_app/Controller/order/order_controller.dart';
// import 'package:restaurant_app/Controller/order/orders_model.dart';
// import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
// import 'package:restaurant_app/Widgets/constants/strings.dart';

// class NotificationController {
//   static final notifications = FlutterLocalNotificationsPlugin();
//   static int orderCount = 0;
//   static String uid = '';
//   static late BuildContext context;
  

//   static NotificationDetails notificationDetails = const NotificationDetails(
//       android: AndroidNotificationDetails('1', 'Orders',
//           channelDescription: "New orders Notifications",
//           priority: Priority.high,
//           importance: Importance.high),
//       iOS: DarwinNotificationDetails(presentSound: true));

//   static Future<void> init(Function navigate, BuildContext context1) async {
//     getPermissions();
    // const initialSettings = InitializationSettings(
    //     android: AndroidInitializationSettings("@mipmap/launcher_icon"),
    //     iOS: DarwinInitializationSettings());
    // await notifications.initialize(
    //   initialSettings,
    //   onDidReceiveNotificationResponse: (details) {
        // navigate(2);
    //   },
//     // );
//     // context = context1;
//     // uid = SharedPrefsUtil().getString(AppStrings.userId)!;
//     // initStream();
//   }

//   static Future<void> showNotification() async {
//     notifications.show(Random.secure().nextInt(200), "New order received",
//         "Go to orders section...", notificationDetails);
//   } 

//   static void getPermissions() {
//     Permission.notification.isDenied.then((denied) {
//       if (denied) {
//         Permission.notification.request();
//       }
//     });
//   }

//   // static void initStream() async {
//   //   final result =
//   //       await OrderController.getAllOrders(context: context, uid: uid);
//   //   result.fold((String message) {
//   //     print(message);
//   //   }, (OrdersModel ordersModel) {
//   //     if (ordersModel.orders != null) {
//   //       orderCount = ordersModel.orders!.length;
//   //     }
//   //   });
//   //   stream = Timer.periodic(const Duration(seconds: 15), (_) async {
//   //     final result =
//   //         await OrderController.getAllOrders(context: context, uid: uid);
//   //     result.fold((String message) {
//   //       print(message);
//   //     }, (OrdersModel ordersModel) {
//   //       if (ordersModel.orders != null) {
//   //         int temp = ordersModel.orders!.length;
//   //         if (temp != orderCount) {
//   //           orderCount = temp;
//   //           showNotification();
//   //         }
//   //       }
//   //     });
//   //   });
//   // }
// }
