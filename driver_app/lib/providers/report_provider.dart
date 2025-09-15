import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../controller/earnings/earnings_controller.dart';
import '../controller/toast.dart';
import '../widgets/constants/shared_preferences.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required this.getMounted}) {
    loadData();
  }
  List<double> weeklyData = [];
  List<double> todayData = [];
  List<double> monthlyData = [0, 0, 0, 0, 0];
  Function getMounted;
  bool isLoading = true;
  List<Map> earnings = [];
  List<Map> weekEarning = [];
  List<Map> todayEarning = [];
  String userid = SharedPrefsUtil().getString('uid')!;
  double totalToday = 0.0;
  double totalWeek = 0.0;
  double totalMonth = 0.0;
  int activeChipIndex = 0;
  void toggleChip(int index) {
    activeChipIndex = index;
    notifyListeners();
  }

  void loadData() async {
    try {
      Toast.showToast(message: "Loading Data");
      final Map response = await EarningsController.getEarnings(uid: userid);
      if (response.containsKey("earnings")) {
        final temp = response['earnings']['earnings'];
        for (Map earning in temp) {
          if (int.tryParse(earning['orderId'].toString().substring(2, 4)) ==
              DateTime.now().month) {
            earnings.add(earning);
            totalMonth += earning['amount'].toDouble();
          }
        }
        await sortData();
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
    for (int i = 0; i < todayEarning.length; i++) {
      todayData.add(todayEarning[i]['amount'].toDouble());
    }
    getWeekly();
    if (getMounted()) {
      notifyListeners();
    }
    // Toast.showToast(message: "Data Loaded");
  }

  String getBannerString() {
    switch (activeChipIndex) {
      case 0:
        return "Today";
      case 1:
        return "This Week";
      case 2:
        return "This Month";
      default:
        return "Today";
    }
  }

  String getBannerAmount() {
    switch (activeChipIndex) {
      case 0:
        return totalToday.toStringAsFixed(2);
      case 1:
        return totalWeek.toStringAsFixed(2);
      case 2:
        return totalMonth.toStringAsFixed(2);
      default:
        return totalToday.toStringAsFixed(2);
    }
  }

  Future<void> sortData() async {
    int weekDay = DateTime.now().weekday;
    int todayDate = DateTime.now().day;
    for (Map earning in earnings) {
      int date = int.parse(earning['orderId'].toString().substring(0, 2));
      if (date == todayDate) {
        todayEarning.add(earning);
        totalToday += earning['amount'].toDouble();
      }
      if (todayDate - date <= weekDay) {
        totalWeek += earning['amount'].toDouble();
        weekEarning.add(earning);
      }
    }
  }

  void getWeekly() {
    weeklyData.clear();
    if (weeklyData.isNotEmpty) {
      String test = weekEarning[0]['orderId'].toString().substring(0, 2);
      double amount = 0;
      for (int i = 0; i < weekEarning.length; i++) {
        if (weekEarning[i]['orderId'].toString().startsWith(test)) {
          amount += weekEarning[i]['amount'];
        } else {
          weeklyData.add(amount);
          amount = weekEarning[i]['amount'].toDouble();
          test = weekEarning[i]['orderId'].toString().substring(0, 2);
        }
      }
      weeklyData.add(amount);
      for (int i = weeklyData.length; i < 7; i++) {
        weeklyData.add(0.0);
      }
    }
    for (var item in earnings) {
      int i = int.tryParse(item['orderId'].toString().substring(0, 2))!;
      if (i <= 7) {
        monthlyData[0] += item['amount'].toDouble();
      } else if (i <= 14) {
        monthlyData[1] += item['amount'].toDouble();
      } else if (i <= 21) {
        monthlyData[2] += item['amount'].toDouble();
      } else if (i <= 28) {
        monthlyData[3] += item['amount'].toDouble();
      } else if (i <= 31) {
        monthlyData[4] += item['amount'].toDouble();
      }
    }
  }
}
