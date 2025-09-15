import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';

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
      }
    });
    
    // Get and log FCM token for both platforms
    try {
      String? token;
      if (Platform.isIOS) {
        // For iOS, get both APNs and FCM tokens for better debugging
        String? apnsToken = await messaging.getAPNSToken();
        token = await messaging.getToken();
        print('🍎 iOS APNs Token: ${apnsToken ?? "NULL"}');
        print('🔥 iOS FCM Token: ${token ?? "NULL"}');
      } else {
        token = await messaging.getToken();
        print('🤖 Android FCM Token: ${token ?? "NULL"}');
      }
      
      if (token != null) {
        addTokenOnFirebase(token);
        print('✅ FCM Token saved to Firestore successfully');
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
    
    messaging.onTokenRefresh.listen((token) {
      print('🔄 FCM Token refreshed: $token');
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
        // Handle notification response here
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
    await messaging.requestPermission();
  }

  static void addTokenOnFirebase(String? token) {
    final uid = SharedPrefsUtil().getString(AppStrings.userId);
    print('📝 Saving FCM Token for user: $uid');
    print('🔑 Token: ${token ?? "NULL"}');
    
    if (uid != null && token != null) {
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
            FirebaseFirestore.instance.collection('fcmTokens').doc('user'),
            {uid: token});
        print('✅ Token saved to Firestore: fcmTokens/user/$uid');
      }).catchError((error) {
        print('❌ Error saving token to Firestore: $error');
      });
    } else {
      print('❌ Cannot save token - UID: $uid, Token: $token');
    }
  }

  // Method to get current FCM token for testing
  static Future<String?> getCurrentToken() async {
    try {
      String? token;
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        token = await messaging.getToken();
        print('🔍 Debug - iOS APNs Token: ${apnsToken ?? "NULL"}');
        print('🔍 Debug - iOS FCM Token: ${token ?? "NULL"}');
      } else {
        token = await messaging.getToken();
        print('🔍 Debug - Android FCM Token: ${token ?? "NULL"}');
      }
      return token;
    } catch (e) {
      print('❌ Error getting current token: $e');
      return null;
    }
  }

  // Comprehensive iOS FCM Flow Test
  static Future<Map<String, dynamic>> testIOSNotificationFlow() async {
    print('🧪 ========== iOS FCM NOTIFICATION FLOW TEST ==========');
    
    Map<String, dynamic> testResults = {
      'platform': Platform.operatingSystem,
      'isIOS': Platform.isIOS,
      'permissions': {},
      'tokens': {},
      'errors': [],
      'firestore': {},
      'summary': ''
    };

    try {
      // 1. Check Platform
      print('🔍 Platform Check: ${Platform.operatingSystem}');
      
      // 2. Check Firebase Messaging Instance
      print('🔍 Firebase Messaging Instance: ${messaging.toString()}');
      
      // 3. Request Permissions
      print('🔍 Testing Notification Permissions...');
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      testResults['permissions'] = {
        'authorizationStatus': settings.authorizationStatus.toString(),
        'alert': settings.alert.toString(),
        'badge': settings.badge.toString(),
        'sound': settings.sound.toString(),
      };
      
      print('✅ Permission Status: ${settings.authorizationStatus}');
      print('✅ Alert: ${settings.alert}');
      print('✅ Badge: ${settings.badge}');
      print('✅ Sound: ${settings.sound}');

      // 4. Test Token Generation
      print('🔍 Testing Token Generation...');
      
      if (Platform.isIOS) {
        // Test APNs Token
        try {
          String? apnsToken = await messaging.getAPNSToken();
          testResults['tokens']['apnsToken'] = apnsToken ?? 'NULL';
          print('🍎 APNs Token: ${apnsToken ?? "NULL"}');
        } catch (e) {
          testResults['errors'].add('APNs Token Error: $e');
          print('❌ APNs Token Error: $e');
        }
        
        // Test FCM Token
        try {
          String? fcmToken = await messaging.getToken();
          testResults['tokens']['fcmToken'] = fcmToken ?? 'NULL';
          print('🔥 FCM Token: ${fcmToken ?? "NULL"}');
        } catch (e) {
          testResults['errors'].add('FCM Token Error: $e');
          print('❌ FCM Token Error: $e');
        }
      }

      // 5. Test Firestore Connection
      print('🔍 Testing Firestore Token Storage...');
      final uid = SharedPrefsUtil().getString(AppStrings.userId);
      
      if (uid != null) {
        testResults['firestore']['userId'] = uid;
        print('✅ User ID Found: $uid');
        
        // Test if we can access Firestore
        try {
          await FirebaseFirestore.instance
              .collection('fcmTokens')
              .doc('user')
              .get();
          testResults['firestore']['firestoreAccess'] = 'SUCCESS';
          print('✅ Firestore Access: SUCCESS');
        } catch (e) {
          testResults['firestore']['firestoreAccess'] = 'ERROR: $e';
          print('❌ Firestore Access Error: $e');
        }
      } else {
        testResults['firestore']['userId'] = 'NULL - User not logged in';
        print('❌ User ID not found - User not logged in');
      }

      // 6. Generate Summary
      bool hasValidToken = testResults['tokens']['fcmToken'] != null && 
                          testResults['tokens']['fcmToken'] != 'NULL';
      bool hasPermissions = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      if (hasValidToken && hasPermissions) {
        testResults['summary'] = '✅ iOS FCM Flow: WORKING - Token generated successfully';
      } else if (!hasPermissions) {
        testResults['summary'] = '⚠️ iOS FCM Flow: PERMISSIONS ISSUE - Notifications not authorized';
      } else {
        testResults['summary'] = '❌ iOS FCM Flow: TOKEN ISSUE - FCM token not generated';
      }

      print('🧪 ========== TEST COMPLETED ==========');
      print(testResults['summary']);
      
      return testResults;
      
    } catch (e) {
      testResults['errors'].add('General Test Error: $e');
      testResults['summary'] = '❌ iOS FCM Flow: CRITICAL ERROR - $e';
      print('❌ Critical Test Error: $e');
      return testResults;
    }
  }

  // Comprehensive notification validation method
  static Future<Map<String, dynamic>> validateNotificationSetup() async {
    Map<String, dynamic> validationResults = {};
    
    try {
      // 1. Platform Check
      validationResults['platform'] = {
        'status': 'success',
        'message': 'Platform: ${Platform.operatingSystem}',
        'details': Platform.isIOS ? 'iOS Device' : 'Android Device'
      };
      
      // 2. Firebase Messaging Check
      validationResults['firebase_messaging'] = {
        'status': 'success',
        'message': 'Firebase Messaging initialized',
        'details': 'Firebase instance available'
      };
      
      // 3. Permission Check
      try {
        NotificationSettings settings = await messaging.requestPermission();
        bool hasPermissions = settings.authorizationStatus == AuthorizationStatus.authorized;
        
        validationResults['permissions'] = {
          'status': hasPermissions ? 'success' : 'warning',
          'message': hasPermissions ? 'Notification permissions granted' : 'Notification permissions denied',
          'details': 'Status: ${settings.authorizationStatus}'
        };
      } catch (e) {
        validationResults['permissions'] = {
          'status': 'error',
          'message': 'Error checking permissions',
          'details': e.toString()
        };
      }
      
      // 4. Token Generation Check
      try {
        String? token;
        if (Platform.isIOS) {
          token = await messaging.getToken();
          String? apnsToken = await messaging.getAPNSToken();
          validationResults['token_generation'] = {
            'status': token != null ? 'success' : 'error',
            'message': token != null ? 'FCM token generated successfully' : 'Failed to generate FCM token',
            'details': 'FCM: ${token ?? "NULL"}, APNs: ${apnsToken ?? "NULL"}'
          };
        } else {
          token = await messaging.getToken();
          validationResults['token_generation'] = {
            'status': token != null ? 'success' : 'error',
            'message': token != null ? 'FCM token generated successfully' : 'Failed to generate FCM token',
            'details': 'Token: ${token ?? "NULL"}'
          };
        }
      } catch (e) {
        validationResults['token_generation'] = {
          'status': 'error',
          'message': 'Error generating token',
          'details': e.toString()
        };
      }
      
      // 5. User Authentication Check
      try {
        final uid = SharedPrefsUtil().getString(AppStrings.userId);
        validationResults['user_auth'] = {
          'status': uid != null ? 'success' : 'warning',
          'message': uid != null ? 'User logged in' : 'User not logged in',
          'details': uid != null ? 'UID available' : 'No user ID found'
        };
      } catch (e) {
        validationResults['user_auth'] = {
          'status': 'error',
          'message': 'Error checking user authentication',
          'details': e.toString()
        };
      }
      
      // 6. Firestore Connection Check
      try {
        await FirebaseFirestore.instance
            .collection('fcmTokens')
            .doc('user')
            .get();
        validationResults['firestore_connection'] = {
          'status': 'success',
          'message': 'Firestore connection successful',
          'details': 'Can access fcmTokens collection'
        };
      } catch (e) {
        validationResults['firestore_connection'] = {
          'status': 'error',
          'message': 'Firestore connection failed',
          'details': e.toString()
        };
      }
      
    } catch (e) {
      validationResults['general_error'] = {
        'status': 'error',
        'message': 'Critical validation error',
        'details': e.toString()
      };
    }
    
    return validationResults;
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
