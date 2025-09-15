import 'package:driver_app/controller/earnings/earnings_controller.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EarningProvider extends ChangeNotifier {
  EarningProvider() {
    getEarnings();
  }
  bool isLoading = true;
  double total = 0;
  double allEarningsTotal = 0;
  bool showAll = true;
  DateTime date = DateTime.now();
  List earnings = [];
  List displayedEarnings = [];
  void getEarnings() async {
    isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userid = prefs.getString('uid')!;
    print(userid);
    try {
      final Map response = await EarningsController.getEarnings(uid: userid);
      if (response.containsKey("earnings")) {
        earnings = response['earnings']['earnings'].reversed.toList();
        if (showAll) {
          displayedEarnings.addAll(earnings);
        } else {
          updateDisplayedEarnings(date);
        }
        for (var earning in earnings) {
          allEarningsTotal += earning['amount'];
        }
      } else {
        Toast.showToast(message: "Something went wrong", isError: true);
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }

  void updateDisplayedEarnings(DateTime date) {
    total = 0;
    String filterKey = DateFormat('ddMMyy').format(date);
    // date.toString().substring(0, 10).replaceAll("-", '').trim();
    displayedEarnings.clear();
    earnings.forEach((earning) {
      if (earning['orderId'].toString().startsWith(filterKey)) {
        displayedEarnings.add(earning);
        total += earning['amount'];
      }
    });
  }

  void pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != date) {
      date = pickedDate;
      updateDisplayedEarnings(date);
      toggleShowAll(false);
      // notifyListeners();
    }
  }

  void toggleShowAll(bool value) {
    showAll = value;
    if (value) {
      displayedEarnings.clear();
      displayedEarnings.addAll(earnings);
    } else {
      updateDisplayedEarnings(date);
    }
    notifyListeners();
  }
}
