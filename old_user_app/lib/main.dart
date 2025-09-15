import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:user_app/Screens/splashScreen.dart';
import 'package:user_app/firebase_options.dart';
import 'package:user_app/utils/uniservice.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/Theme.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await UniService.init();
  await SharedPrefsUtil().init();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isdark = prefs.getBool('isDarkTheme') ?? false;
  // try {
  //   await dotenv.load(fileName: ".env");
  // } catch (e) {
  //   print('Error loading .env file: $e');
  // }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_fcmBgHandler);
  await getBackendLink();
  runApp(MainApp(
    isdarkmode: isdark,
  ));
}

//background Notifications Service
@pragma('vm:entry-point')
Future<void> _fcmBgHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MainApp extends StatelessWidget {
  final bool isdarkmode;
  const MainApp({super.key, required this.isdarkmode});

  // final ThemeData _themeData = AppTheme.light;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
            providers: [
              ChangeNotifierProvider<Themes>(
                  create: (context) => Themes(isdarkmode)),
              ChangeNotifierProvider<GlobalProvider>(
                  create: (context) => GlobalProvider())
            ],
            builder: (context, snapshot) {
              //  final apptheme = context.read<Themes>();
              final apptheme = Provider.of<Themes>(context);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: apptheme.currenttheme, // Directly use _themeData
                home: UpgradeAlert(
                    dialogStyle: defaultTargetPlatform == TargetPlatform.iOS
                        ? UpgradeDialogStyle.cupertino
                        : UpgradeDialogStyle.material,
                    showIgnore: false,
                    showLater: false,
                    showReleaseNotes: false,
                    child: const SplashScreen()),
              );
            });
      },
    );
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
