import 'dart:developer';

import 'package:app_links/app_links.dart';

class UniService {
  static String? referralCode;
  static String? executiveId;
  static AppLinks appLinks = AppLinks();

  static init() async {
    try {
      final Uri? uri = await appLinks.getInitialLink();
      if (uri != null) {
        referralCode = uri.queryParameters['code'];
        executiveId = uri.queryParameters['code'];
      }
    } catch (e) {
      log(e.toString());
    }
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.queryParameters.isNotEmpty) {
        if (uri.queryParameters['code'] != null) {
          referralCode = uri.queryParameters['code'];
          executiveId = uri.queryParameters['code'];
          // Toast.showToast(
          //     message: 'Referral code=$referralCode', isError: false);
        }
      }
    }, onError: (error) {
      log('Uri Error : ${error.toString()}');
    });
  }
}
