import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/payments_controller.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:restaurant_app/homeScreen.dart';
import 'package:sizer/sizer.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen(
      {super.key,
      required this.amount,
      required this.itemToBePurchased,
      required this.onPaymentSuccess});
  final double amount;

  /// For example Subscription/ Ads
  final String itemToBePurchased;
  final Function onPaymentSuccess;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool walletUsed = false;
  double walletCashToBeUsed = 0;

  @override
  void initState() {
    super.initState();
    walletCashToBeUsed = WalletController.wallet!.amount! > widget.amount
        ? widget.amount
        : WalletController.wallet!.amount!;
    // setState(() {});
  }

  void checkout() async {
    if (walletUsed) {
      if (walletCashToBeUsed == widget.amount) {
        if (await widget.onPaymentSuccess()) {
          WalletController.debit(
              widget.amount, "${widget.itemToBePurchased} purchased");
          Navigator.of(context).pushAndRemoveUntil(
              transitionToNextScreen(const HomeScreen()), (_) => false);
        }
      } else {
        PaymentController paymentController =
            PaymentController(onSuccess: (txnId) async {
          WalletController.debit(
              walletCashToBeUsed, "${widget.itemToBePurchased} Purchased");
          if (!(await widget.onPaymentSuccess())) {
            showDialog(
                context: context,
                builder: (context) => Dialog(
                      insetPadding: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Unable to complete the purchase, Please note the transaction I'd and contact support to get refund.\n$txnId",
                            textAlign: TextAlign.center),
                      ),
                    ));
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                transitionToNextScreen(const HomeScreen()), (_) => false);
          }
        }, onFailure: () {
          Toast.showToast(message: "Payment Failed", isError: true);
        });
        if (await paymentController.createOrder(
            amountInRupees: widget.amount - walletCashToBeUsed)) {
          paymentController.initPayment(widget.amount - walletCashToBeUsed);
        }
      }
    } else {
      PaymentController paymentController =
          PaymentController(onSuccess: (txnId) async {
        if (!(await widget.onPaymentSuccess())) {
          showDialog(
              context: context,
              builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Unable to complete the purchase, Please note the transaction I'd and contact support to get refund.\n$txnId",
                          textAlign: TextAlign.center),
                    ),
                  ));
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              transitionToNextScreen(const HomeScreen()), (_) => false);
        }
      }, onFailure: () {
        Toast.showToast(message: "Payment Failed", isError: true);
      });
      if (await paymentController.createOrder(amountInRupees: widget.amount)) {
        paymentController.initPayment(widget.amount);
      }
    }
  }

  // Future<bool> subscribe() async {
  //   String time = DateTime.now().toIso8601String();
  //   final subscribeRequest = SubscribeRequestModel(
  //       subscribeById: SharedPrefsUtil().getString(AppStrings.userId)!,
  //       role: 'Restaurant',
  //       subscriptionPlanId: 'widget.amount - 4 Month',
  //       startDate: time);
  //   return await SubscribeController.subscribeUser(
  //       context: context, subscribeRequest: subscribeRequest);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payouts', style: h4TextStyle),
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
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/otpbg.png'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.itemToBePurchased} Fee'),
                    Text('₹ ${widget.amount}',
                        style: TextStyle(fontWeight: FontWeight.w600))
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.only(right: 15),
                  leading: Checkbox(
                    value: walletUsed,
                    onChanged: (value) {
                      walletUsed = value!;
                      setState(() {});
                    },
                  ),
                  title: Text("Use Wallet Cash"),
                  trailing: Text("₹ ${walletCashToBeUsed.toStringAsFixed(2)}",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${widget.itemToBePurchased} Fee'),
                        Text('₹ ${widget.amount}',
                            style: TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wallet Cash Used'),
                        Text(
                            '- ₹ ${walletUsed ? walletCashToBeUsed.toStringAsFixed(2) : 0}',
                            style: TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total'),
                        Text(
                            '₹ ${walletUsed ? widget.amount - walletCashToBeUsed : widget.amount}',
                            style: TextStyle(fontWeight: FontWeight.w600))
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: mainButton("Checkout", Colors.white, () {
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
