import 'dart:convert';
import 'dart:developer';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WalletController {
  static bool loaded = false;
  static String uid = '';
  // static final String baseurl = dotenv.env['BASE_URL']!;
  static String baseurl = AppStrings.baseURL;
  static Wallet? wallet;

  static Future<void> getUserId({String? phoneNumber}) async {
    if (phoneNumber == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString('contact_number');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseurl/auth/getDeliveryBoyUIDbyPhoneNumber'),
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

  static Future<String> createWallet(
      String phoneNumber, String username) async {
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
          "type": "rider",
          "status": "created"
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        loaded = true;
      }
    } catch (e) {
      print(e);
    }
    return uid;
  }

  static Future<void> getWallet() async {
    if (uid.isEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('uid') != null) {
        uid = prefs.getString('uid')!;
      } else {
        await getUserId();
      }
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
            "status": "credited: $message",
            "type": 'rider',
            "username": wallet!.username
          }));
      if (response.statusCode == 200) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        return true;
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(response.body);
          print("rider: $uid");
        }
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      }
      return false;
    }
  }

  static Future<bool> creditToRestaurant(
      String restaurantuid, double amount, String message, String name) async {
    try {
      final response =
          await http.put(Uri.parse('$baseurl/wallet/wallet/$restaurantuid'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "amount": amount,
                "status": "credited: $message",
                "type": 'restaurant',
                "username": name
              }));
      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(response.body);
          print("restaurant: $restaurantuid");
        }
        return false;
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      }
      return false;
    }
  }

  static Future<bool> creditToUser(
      String restaurantuid, double amount, String message, String name) async {
    try {
      final response =
          await http.put(Uri.parse('$baseurl/wallet/wallet/$restaurantuid'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "amount": amount,
                "status": "credited: $message",
                "type": 'user',
                "username": name
              }));
      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(response.body);
          print("user: $restaurantuid");
        }
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
            "status": "debited: $message",
            "type": 'rider',
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

  Wallet(
      {this.walletId,
      this.uid,
      this.amount,
      this.updates,
      this.username,
      this.type});

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
