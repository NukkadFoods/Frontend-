import 'package:flutter/material.dart';

class PaymentTypeController {
  // Private constructor
  PaymentTypeController._privateConstructor();

  // Single instance
  static final PaymentTypeController _instance = PaymentTypeController._privateConstructor();

  // Factory constructor to return the instance
  factory PaymentTypeController() {
    return _instance;
  }
 ValueNotifier<int> selectedPaymentMethod = ValueNotifier<int>(-1);

  void setPaymentMethod(int value) {
    selectedPaymentMethod.value = value;
  }
}
