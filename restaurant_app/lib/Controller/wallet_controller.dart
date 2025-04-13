import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/toast.dart';

class WalletController {
  static bool loaded = false;
  static String uid = '';
  // static final String baseurl = dotenv.env['BASE_URL']!;
  static final String baseurl = AppStrings.baseURL;
  static Wallet? wallet;

  static Future<void> getUserId({String? phoneNumber}) async {
    if (phoneNumber == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString(AppStrings.mobilenumber);
    }
    try {
      final response = await http.post(
        Uri.parse('$baseurl/auth/getRestaurantUIDbyPhoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "phoneNumber": phoneNumber,
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        uid = jsonDecode(response.body)['uid'];
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> createWallet(String phoneNumber, String username) async {
    await getUserId(phoneNumber: phoneNumber);
    print('$baseurl/wallet/createWallet');
    try {
      final response = await http.post(
        Uri.parse('$baseurl/wallet/wallet'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "uid": uid, // User's unique ID (required)
          "amount": 0, // Initial amount in the wallet (required)
          "username": username,
          "type": "restaurant",
          "status": "created"
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> getWallet() async {
    if (uid.isEmpty) {
      uid = SharedPrefsUtil().getString(AppStrings.userId)!;
    }
    try {
      final response = await http.get(Uri.parse("$baseurl/wallet/wallet/$uid"),
          headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        loaded = true;
      } else {
        log(response.statusCode.toString());
        print(response.body.toString());
        Toast.showToast(message: 'Error Loading Wallet', isError: true);
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      }
    }
  }

  static Future<bool> credit(double amount, String message) async {
    try {
      final response = await http.put(Uri.parse('$baseurl/wallet/wallet/$uid'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": amount,
            "status": "credited $message",
            "type": "restaurant",
            "username": wallet!.username
          }));
      if (response.statusCode == 200) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        return true;
      } else {
        print(response.statusCode);
        print(response.body);
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      }
      return false;
    }
  }

  static Future<bool> debit(double amount, String message) async {
    try {
      final response = await http.put(Uri.parse('$baseurl/wallet/wallet/$uid'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": -amount,
            "status": "debited $message",
            "type": "restaurant",
            "username": wallet!.username
          }));
      if (response.statusCode == 200) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        return true;
      } else {
        print(response.statusCode);
        print(response.body);
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      }
      return false;
    }
  }

  static Future<bool> deleteWallet() async {
    try {
      final response = await http.delete(
          Uri.parse("$baseurl/wallet/wallet/$uid"),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        wallet = null;
        loaded = false;
        return true;
      } else {
        if (kDebugMode) {
          log('Error: ${response.statusCode}');
          print('Error body: ${response.body}');
        }
        Toast.showToast(message: 'Error Loading Wallet', isError: true);
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      } else {
        log('Exception occurred: $e');
      }
      return false;
    }
  }
}

/// Wallet Model
class Wallet {
  String? walletId;
  String? uid;
  String? type;
  String? username;
  double? amount;
  List<Updates>? updates;

  Wallet({this.walletId, this.uid, this.amount, this.updates});

  Wallet.fromJson(Map<String, dynamic> json) {
    walletId = json['_id'];
    uid = json['uid'];
    username = json['username'];
    type = json['type'];
    amount = double.tryParse(json['amount'].toString());
    if (json['updates'] != null) {
      updates = <Updates>[];
      json['updates'].forEach((v) {
        updates!.add(Updates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = walletId;
    data['uid'] = uid;
    data['username'] = username;
    data['type'] = type;
    data['amount'] = amount;
    if (updates != null) {
      data['updates'] = updates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Updates {
  double? amount;
  String? status;
  String? date;

  Updates({this.amount, this.status, this.date});

  Updates.fromJson(Map<String, dynamic> json) {
    amount = double.tryParse(json['amount'].toString());
    status = json['status'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['status'] = status;
    data['date'] = date;
    return data;
  }
}
