import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/firebase_options.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/uni_service.dart';
import 'package:driver_app/widgets/constants/shared_preferences.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'screens/other_screens/splash_screen.dart';

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await UniService.init();
  await SharedPrefsUtil().init();
  // try {
  //   print("HELLLOOO");
  //   await dotenv.load(fileName: ".env");
  //   print("loaded");
  // } catch (e) {
  //   print('Error loading .env file: $e');
  // }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_fcmBgHandler);
  await getBackendLink();
  runApp(const MyApp());
}

//background Notifications Service
@pragma('vm:entry-point')
Future<void> _fcmBgHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(message.data);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'Nukkad Foods Driver',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: colorBrightGreen),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: UpgradeAlert(
            dialogStyle: defaultTargetPlatform == TargetPlatform.iOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            showIgnore: false,
            showLater: false,
            showReleaseNotes: false,
            child: const SplashScreen()),
        // home: const BottomNavBar(),
      );
    });
  }
}

Future<void> getBackendLink() async {
  String link = (await FirebaseFirestore.instance
              .collection('constants')
              .doc('common')
              .get())
          .get('baseUrl') ??
      "https://nukkad-foods-backend.vercel.app/api";
  AppStrings.baseURL = link;
  SharedPrefsUtil().setString('base_url', link);
}
