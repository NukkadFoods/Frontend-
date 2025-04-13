import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';

class NotificationService {
  NotificationService._();
  static final notifications = FlutterLocalNotificationsPlugin();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static Function? orderRefresh;

  static NotificationDetails orderNotificationDetails =
      const NotificationDetails(
          android: AndroidNotificationDetails('orders', 'Orders',
              channelDescription: "New orders Notifications",
              priority: Priority.max,
              importance: Importance.max),
          iOS: DarwinNotificationDetails(presentSound: true));

  static Future<void> init(Function(int) onTapNotification) async {
    getPermissions();
    initLocalNotifications(onTapNotification);
    FirebaseMessaging.onMessage.listen((message) {
      if (orderRefresh != null) {
        orderRefresh!();
      }
      if (message.notification != null) {
        showNotification(message.notification!.title ?? "",
            message.notification!.body ?? '', orderNotificationDetails,
            payload: jsonEncode(message.data));
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

  static void initLocalNotifications(Function(int) navigate) async {
    const initialSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/launcher_icon"),
        iOS: DarwinInitializationSettings());
    await notifications.initialize(
      initialSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null &&
            jsonDecode(details.payload!)['orderId'] != null) {
          navigate(2);
        }
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
    await messaging.requestPermission();
  }

  static void addTokenOnFirebase(String? token) {
    final uid = SharedPrefsUtil().getString(AppStrings.userId);
    if (uid != null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
            FirebaseFirestore.instance
                .collection('fcmTokens')
                .doc('restaurant'),
            {uid: token});
      });
    }
  }

  static Future<void> sendNotification({
    required String toUid,
    required String toApp,
    required String title,
    required String body,
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
