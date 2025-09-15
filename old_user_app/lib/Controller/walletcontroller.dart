import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class WalletController {
  static bool loaded = false;
  static String uid = '';
  // static final String baseurl = dotenv.env['BASE_URL']!;
  static final String baseurl = SharedPrefsUtil().getString('base_url')!;
  static Wallet? wallet;

  static Future<void> createWallet(
      BuildContext context, String username) async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    if (username.isEmpty) {
      final result =
          await UserController.getUserById(context: context, id: userId);
      result.fold((message) {
        return;
      }, (user) {
        username = user.user!.username!;
      });
    }
    if (username.isEmpty) {
      return;
    }
    print('${AppStrings.baseURL}/wallet/createWallet');
    try {
      final response = await http.post(
        Uri.parse('$baseurl/wallet/wallet'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "uid": userId, // User's unique ID (required)
          "amount": 00, // Initial amount in the wallet (required)
          "username": username,
          "type": "user",
          "status": "createdWallet"
        }),
      );
      print('user by phone ${response.body}');
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
      final temp = SharedPrefsUtil().getString(AppStrings.userId);
      if (temp == null) {
        return;
      } else {
        uid = temp;
      }
    }
    print('Fetching wallet for uid: $uid');

    try {
      final response = await http.get(Uri.parse("$baseurl/wallet/wallet/$uid"),
          headers: {"Content-Type": "application/json"});

      if (response.statusCode == 200) {
        wallet = Wallet.fromJson(jsonDecode(response.body)['wallet']);
        loaded = true;
      } else {
        if (kDebugMode) {
          log('Error: ${response.statusCode}');
          print('Error body: ${response.body}');
        }
        Toast.showToast(message: 'Error Loading Wallet', isError: true);
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: 'No Internet', isError: true);
      } else {
        log('Exception occurred: $e');
      }
    }
  }

  static Future<bool> credit(double amount, String reason) async {
    try {
      final response = await http.put(Uri.parse('$baseurl/wallet/wallet/$uid'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": amount,
            "status": "credited $reason",
            "type": "user",
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

  static Future<bool> creditToOtherUser(
      String uid, double amount, String message, String name) async {
    try {
      final response = await http.put(Uri.parse('$baseurl/wallet/wallet/$uid'),
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

  static Future<bool> debit(double amount, String reason) async {
    try {
      final response = await http.put(Uri.parse('$baseurl/wallet/wallet/$uid'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": -amount,
            "status": "debited $reason",
            "type": "user",
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

    // Handling amount as dynamic (int or double)
    if (json['amount'] is int) {
      amount = (json['amount'] as int).toDouble();
    } else {
      amount = json['amount'];
    }

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
    data['type'] = type;
    data['username'] = username;
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
