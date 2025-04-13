import 'dart:convert';

import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/controller/toast.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ComplaintsProvider extends ChangeNotifier {
  ComplaintsProvider() {
    getComplaints();
  }
  Map<String, OrderData> loadedOrderData = {};
  List complaintsDataList = [];
  List filteredComplaints = [];
  bool isLoading = true;
  int selected = 0;
  List<String> tabs = ['All', 'New', 'Resolved', 'Verified', 'Processing'];
  void changeSelected(int a) {
    selected = a;
    filterComplaints();
    notifyListeners();
  }

  Future<void> getComplaints() async {
    isLoading = true;
    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      String baseUrl = AppStrings.baseURL;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userid = prefs.getString('uid')!;
      final response =
          await http.get(Uri.parse('$baseUrl/complaint/getAllComplaints'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          isLoading = false;
          complaintsDataList.clear();
          for (Map<String, dynamic> complaint in responseData['complaints']) {
            if (complaint['complaint_done_against_role']
                    .toString()
                    .toLowerCase() ==
                "rider") {
              if (complaint['complaint_done_against_id'] == userid) {
                complaintsDataList.add(complaint);
              }
            }
          }
          // complaintsDataList = responseData['complaints'];
          filterComplaints();
        } else {
          isLoading = false;
          Toast.showToast(message: 'Internal Server Error', isError: true);
        }
      } else {
        isLoading = false;
        print(response.body);
        Toast.showToast(message: "Failed to get complaints", isError: true);
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     backgroundColor: colorFailure,
        //     content: Text("Failed to get complaints order")));
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
    }
    notifyListeners();
  }

  void filterComplaints() {
    if (selected == 0) {
      filteredComplaints = complaintsDataList
          .where((order) =>
              order['status'] == 'Resolved' ||
              order['status'] == 'Verified' ||
              order['status'] == 'Processing')
          .toList();
    } else if (selected > 1) {
      filteredComplaints = complaintsDataList
          .where((order) => order['status'] == tabs[selected])
          .toList();
    }
    notifyListeners();
  }
}
