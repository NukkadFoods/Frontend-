import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/payments_controller.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/utils/extensions.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class SubscriptionCheckout extends StatefulWidget {
  const SubscriptionCheckout(
      {super.key,
      required this.amount,
      required this.fractionWalletUsed,
      required this.plan});

  final double amount, fractionWalletUsed;
  final String plan;
  @override
  State<SubscriptionCheckout> createState() => _SubscriptionCheckoutState();
}

class _SubscriptionCheckoutState extends State<SubscriptionCheckout> {
  double amount = 0;
  bool walletUsed = false;
  double walletCashToBeUsed = 0;
  final _plans = {"WEEKLY": 7, "MONTHLY": 30, "3-MONTH": 90};

  @override
  void initState() {
    super.initState();
    amount = widget.amount;
    walletCashToBeUsed =
        WalletController.wallet!.amount! > amount * widget.fractionWalletUsed
            ? amount * widget.fractionWalletUsed
            : WalletController.wallet!.amount!;
    setState(() {});
  }

  void checkout() async {
    if (walletUsed) {
      if (walletCashToBeUsed == amount) {
        if (await subscribe()) {
          WalletController.debit(amount, "Subscrition purchased");
          Navigator.of(context).popUntil((_) => _.isFirst);
        }
      } else {
        PaymentController paymentController =
            PaymentController(onSuccess: (txnId) async {
          WalletController.debit(walletCashToBeUsed, "Subscription Purchased");
          if (!(await subscribe())) {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Can't Subscribe, Please note the transaction I'd and contact support to get refund.\n$txnId",
                            textAlign: TextAlign.center),
                      ),
                    ));
          } else {
            Toast.showToast(message: "Subscription Purchased", isError: false);
            Navigator.of(context).popUntil((_) => _.isFirst);
          }
        }, onFailure: () {
          Toast.showToast(message: "Payment Failed", isError: true);
        });
        if (await paymentController.createOrder(
            amountInRupees: (amount - walletCashToBeUsed).roundOff())) {
          paymentController
              .initPayment((amount - walletCashToBeUsed).roundOff());
        }
      }
    } else {
      PaymentController paymentController =
          PaymentController(onSuccess: (txnId) async {
        if (!(await subscribe())) {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Can't Subscribe, Please note the transaction I'd and contact support to get refund.\n$txnId",
                          textAlign: TextAlign.center),
                    ),
                  ));
        } else {
          Toast.showToast(message: "Subscription Purchased", isError: false);
          Navigator.of(context).popUntil((_) => _.isFirst);
        }
      }, onFailure: () {
        Toast.showToast(message: "Payment Failed", isError: true);
      });
      if (await paymentController.createOrder(amountInRupees: amount)) {
        paymentController.initPayment(amount);
      }
    }
  }

  Future<bool> subscribe() async {
    DateTime startDate = DateTime.now().toUtc();
    final subscribeRequest = SubscribeRequestModel(
      subscribeById: SharedPrefsUtil().getString(AppStrings.userId)!,
      role: 'User',
      subscriptionPlanId: widget.plan,
      startDate: startDate.toString(),
      endDate:
          startDate.add(Duration(days: _plans[widget.plan] ?? 0)).toString(),
    );
    return await SubscribeController.subscribeUser(
        context: context, subscribeRequest: subscribeRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: h4TextStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 19.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? textBlack
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subscription Fee'),
                    Text('₹ $amount',
                        style: const TextStyle(fontWeight: FontWeight.w600))
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? textBlack
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(right: 15),
                  leading: Checkbox(
                    value: walletUsed,
                    onChanged: (value) {
                      walletUsed = value!;
                      setState(() {});
                    },
                  ),
                  title: const Text("Use Wallet Cash"),
                  trailing: Text("₹ ${walletCashToBeUsed.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? textBlack
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subscription Fee'),
                        Text('₹ ${amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Wallet Cash Used'),
                        Text(
                            '₹ ${walletUsed ? walletCashToBeUsed.toStringAsFixed(2) : 0}',
                            style: const TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
                        Text(
                            '₹ ${(walletUsed ? amount - walletCashToBeUsed : amount).roundOff()}',
                            style: const TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: mainButton("Checkout", Colors.white, () async {
                    checkout();
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
