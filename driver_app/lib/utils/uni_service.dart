import 'dart:developer';

import 'package:app_links/app_links.dart';

class UniService {
  static String? name;
  static String? executiveId;
  // static String? referralCode;
  static AppLinks appLinks = AppLinks();

  static init() async {
    try {
      final Uri? uri = await appLinks.getInitialLink();
      if (uri != null && uri.queryParameters.isNotEmpty) {
        executiveId = uri.queryParameters['code'];
        name = uri.queryParameters['name'];
        // referralCode = uri.queryParameters['code'];
      }
    } catch (e) {
      log(e.toString());
    }
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters.isNotEmpty) {
        executiveId = uri.queryParameters['code'];
        // name = uri.queryParameters['name'];
      }
    }, onError: (error) {
      log('Uri Error : ${error.toString()}');
    });
  }
}
