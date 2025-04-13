import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController {
  PaymentController({required this.onSuccess, required this.onFailure}) {
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
  }

  // BuildContext context;

  final Razorpay _razorPay = Razorpay();

  // static final String _baseUrl = dotenv.env['BASE_URL']!;
  static final String _baseUrl = SharedPrefsUtil().getString('base_url')!;
  String? orderId;
  int? amountInPaise;
  String? status;
  String? receipt;
  String? paymentId;
  String? signature;
  final ValueChanged<String?> onSuccess;
  final VoidCallback onFailure;
  Future<bool> createOrder({double? amountInRupees}) async {
    try {
      final response = await http.post(
          Uri.parse('$_baseUrl/payment/createOrder'),
          headers: {AppStrings.contentType: 'application/json'},
          body:
              jsonEncode({"amount": amountInRupees! * 100, "currency": "INR"}));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        orderId = responseData["order"]["id"];
        amountInPaise = responseData["order"]["amount"];
        // status = responseData["order"]["status"];
        receipt = responseData["order"]["receipt"];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('error in order creation');
      print(e);
      return false;
    }
  }

  Future<void> initPayment(double? amountInRupees) async {
    final data = await FirebaseFirestore.instance
        .collection('constants')
        .doc('userApp')
        .get();
    final _apikey = data.data()?['rzp_key'];
    log(orderId!);
    if (amountInRupees != null) {
      _razorPay.open({
        'key': _apikey,
        'order_id': orderId,
        'amount': amountInRupees * 100,
        'name': 'Nukkad Foods',
        'description': 'Order',
        'retry': {'enabled': true, 'max_count': 2},
        'send_sms_hash': true,
        'prefill': {'contact': "+918828767828"},
        'external': {
          'wallets': ['paytm'],
          'upi': ['phonepe']
        }
      });
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    log(response.message.toString());
    print(response.error);
    log('payment failed');
    status = 'failed';
    _razorPay.clear();
    onFailure();
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //   content: Text('Payment Failed'),
    //   backgroundColor: Colors.red,
    // ));
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    paymentId = response.paymentId;
    signature = response.signature;
    log('payment Success!!!');
    status = 'success';
    try {
      print({
                "razorpay_order_id": orderId,
                "razorpay_payment_id": paymentId,
                "razorpay_signature": signature
              });
      final verifyResponse =
          await http.post(Uri.parse('$_baseUrl/payment/verifyPayment'),
              headers: {AppStrings.contentType: 'application/json'},
              body: jsonEncode({
                "razorpay_order_id": orderId,
                "razorpay_payment_id": paymentId,
                "razorpay_signature": signature
              }));
      if (verifyResponse.statusCode == 200) {
        log('payment success');
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //   content: Text('Payment Success'),
        //   backgroundColor: Colors.green,
        // ));
        onSuccess(response.paymentId);
      }else{
        log('verification Error');
        print(verifyResponse.statusCode);
        print(verifyResponse.body);
      }
    } catch (e) {
      print('verification Error');
      print(e);
    }
    _razorPay.clear();
  }
}
