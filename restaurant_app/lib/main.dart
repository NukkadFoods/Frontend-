import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/Screens/splashScreen.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/firebase_options.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'provider/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SharedPrefsUtil().init();
  // try {
  //   await dotenv.load(fileName: ".env");
  //   print("Helloooo");
  // } catch (e) {
  //   print('Error loading .env file: $e');
  // }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_fcmBgHandler);
  await getBackendLink();
  runApp(const MainApp());
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Nukkad Foods',
            debugShowCheckedModeBanner: false,
            home: UpgradeAlert(
                dialogStyle: defaultTargetPlatform == TargetPlatform.iOS
                    ? UpgradeDialogStyle.cupertino
                    : UpgradeDialogStyle.material,
                showIgnore: false,
                showLater: false,
                showReleaseNotes: false,
                child: const SplashScreen()),
            theme: ThemeData(
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
          );
        },
      ),
    );
  }
}

Future<void> getBackendLink() async {
  String link = (await FirebaseFirestore.instance
          .collection('constants')
          .doc('common')
          .get())
      .get('baseUrl');
  AppStrings.baseURL = link;
  SharedPrefsUtil().setString('base_url', link);
}
