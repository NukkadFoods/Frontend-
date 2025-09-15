import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Controller/earnings_controller.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/toast.dart';

class PayoutsProvider extends ChangeNotifier {
  PayoutsProvider() {
    contact = SharedPrefsUtil().getString(AppStrings.mobilenumber)!;
    if (!contact.startsWith('+91')) {
      contact = "+91$contact";
    }
    getPayouts();
  }
  // final String baseurl = dotenv.env['BASE_URL']!;
  final String baseurl = AppStrings.baseURL;
  late String contact;
  final uid = SharedPrefsUtil().getString(AppStrings.userId)!;
  bool isLoading = true;
  List<Map> paidPayouts = [];
  List<Map> pendingPayouts = [];
  Map? latestPayout;
  void getPayouts() async {
    paidPayouts.clear();
    pendingPayouts.clear();
    try {
      final response = await http.get(
        Uri.parse("$baseurl/payoutrequest"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List temp = jsonDecode(response.body)['payoutRequests'];
        temp = temp.reversed.toList();
        for (Map payout in temp) {
          if (payout['accountNumber'] == contact &&
              payout['type'] == 'restaurant') {
            latestPayout ??= payout;
            if (payout["status"] == 'pending') {
              pendingPayouts.add(payout);
            } else {
              paidPayouts.add(payout);
            }
          }
        }
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

  bool enableRequest() {
    if ((pendingPayouts.isNotEmpty || paidPayouts.isNotEmpty) &&
        latestPayout == null) {
      return false;
    }
    if (pendingPayouts.isEmpty && paidPayouts.isEmpty) {
      return true;
    }
    DateTime lastPayoutDate = DateTime.parse(latestPayout!['createdAt']);
    return DateTime.now().isAfter(lastPayoutDate.add(const Duration(days: 7)));
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                "Can't request a new payout since the last payout request was created within last 7 days",
              ),
            ),
          ),
    );
  }

  void requestPayout(BuildContext context) async {
    if (!enableRequest()) {
      if (latestPayout == null) {
        return;
      }
      showAlert(context);
      return;
    }

    bool? proceed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Text(
              'You can request next payout after 7 from the day of requesting last payout only\nDo you want to proceed?',
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primaryColor),
                ),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
            ],
          ),
    );
    if (proceed == null) {
      return;
    }
    final earningData = await Navigator.of(
      context,
    ).push(transitionToNextScreen(EarningSelector()));
    if (earningData != null) {
      double total = earningData['total'];
      List<String> earningIDs = [];
      for (var earning in earningData['earnings']) {
        earningIDs.add(earning['_id']);
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder:
            (context) => Dialog(
              // insetPadding: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    Text('    Creating Payout Request...'),
                  ],
                ),
              ),
            ),
      );
      try {
        final response = await http.post(
          Uri.parse("$baseurl/payoutrequest"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": WalletController.wallet!.username,
            "type": "restaurant",
            "totalAmount": total,
            "earningsID": earningIDs,
            "userID": uid,
            "accountNumber": contact,
          }),
        );

        if (response.statusCode == 201) {
          compute(updateEarnings, <String, dynamic>{
            "uid": uid,
            "baseUrl": AppStrings.baseURL,
            "earnings": earningIDs,
          });
        } else {
          Toast.showToast(message: "Unable to request payout", isError: true);
          if (kDebugMode) {
            print(response.body);
          }
        }
      } catch (e) {
        if (e is http.ClientException) {
          Toast.showToast(message: "No Internet", isError: true);
        }
        if (kDebugMode) {
          print(e);
        }
      }
      Navigator.of(context).pop();
      latestPayout = null;
      getPayouts();
      notifyListeners();
    }
  }

  static FutureOr updateEarnings(Map<String, dynamic> message) async {
    String uid = message['uid'];
    List<String> earnings = message['earnings'];
    EarningsController.endpoint = "${message['baseUrl']}/earnings";
    for (var earning in earnings) {
      await EarningsController.updateEarning(
        uid: uid,
        earningId: earning,
        newStatus: 'completed',
      );
    }
  }
}

class EarningSelector extends StatefulWidget {
  const EarningSelector({super.key});

  @override
  State<EarningSelector> createState() => _EarningSelectorState();
}

class _EarningSelectorState extends State<EarningSelector> {
  final uid = SharedPrefsUtil().getString(AppStrings.userId)!;
  bool isLoading = true;
  List<Map> earnings = [];
  double total = 0;
  @override
  void initState() {
    super.initState();
    getEarnings();
  }

  void getEarnings() async {
    try {
      final Map response = await EarningsController.getEarnings(uid: uid);
      if (response.containsKey("earnings")) {
        List allEarnings = response['earnings']['earnings'].reversed.toList();
        for (Map earning in allEarnings) {
          if (earning['status'] == 'pending') {
            total += earning['amount'].toDouble();
            earnings.add(earning);
          }
        }
      } else {
        Toast.showToast(message: "Something went wrong", isError: true);
      }
    } catch (e) {
      if (e is http.ClientException) {
        Toast.showToast(message: "No Internet", isError: true);
      }
      if (kDebugMode) {
        print(e);
      }
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/images/otpbg.png'),
          opacity: .5,
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(
            "Selected Earnings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (earnings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Total: ${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(
                                0xff435dcf,
                              ).withAlpha((255 * .7).toInt()),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    earnings.isEmpty
                        ? Expanded(
                          child: Center(
                            child: Text("No Pending Earnings Found"),
                          ),
                        )
                        : Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: ListView.builder(
                              itemCount: earnings.length,
                              itemBuilder:
                                  (context, index) => ListTile(
                                    // horizontalTitleGap: 0,
                                    title: Text(earnings[index]['orderId']),
                                    trailing: Text(
                                      '₹ ${earnings[index]['amount']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                  ],
                ),
        floatingActionButton:
            earnings.isEmpty
                ? null
                : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop({'earnings': earnings, 'total': total});
                  },
                  label: Text(
                    'Create Payout Request',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: primaryColor,
                ),
      ),
    );
  }
}
