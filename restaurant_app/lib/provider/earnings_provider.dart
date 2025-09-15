import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:http/http.dart' as http;

import '../Controller/earnings_controller.dart';
import '../Widgets/toast.dart';

class EarningProvider extends ChangeNotifier {
  EarningProvider(this.context) {
    getEarnings();
  }
  BuildContext context;
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
    String userid = SharedPrefsUtil().getString(AppStrings.userId)!;
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
    if (context.mounted) {
      notifyListeners();
    }
  }

  void updateDisplayedEarnings(DateTime date) {
    total = 0;
    final f = DateFormat('ddMMyy');
    String filterKey = f.format(date);
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
    if (pickedDate != null) {
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
