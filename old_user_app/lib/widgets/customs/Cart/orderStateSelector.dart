import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/order/order_model.dart';
import 'package:user_app/Controller/payment/type_of_payment.dart';
import 'package:user_app/Controller/payments_controller.dart';
import 'package:user_app/Controller/user/user_model.dart' as user;
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/screens/Orders/orderProcessingScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:intl/intl.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class OrderStateSelector extends StatefulWidget {
  const OrderStateSelector(
      {super.key,
      required this.context,
      required this.selectedDate,
      required this.selectedTime,
      required this.onDateSelected,
      required this.onTimeSelected,
      required this.cartList,
      required this.restaurantname,
      required this.totalprice,
      required this.restaurantuid,
      required this.drivertip,
      required this.cookingreq,
      required this.code,
      required this.userData,
      required this.discount,
      required this.isDelivery,
      required this.orderCost,
      required this.walletUsed,
      required this.prepTime,
      required this.walletAmount,
      this.deliveryInstruction,
      required this.hubId});
  final BuildContext context;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final List<CartModel> cartList;
  final void Function(DateTime) onDateSelected;
  final void Function(TimeOfDay) onTimeSelected;
  final Map orderCost;
  final String restaurantname;
  final double totalprice;
  final String restaurantuid;
  final String? cookingreq;
  final double? drivertip;
  final String? code;
  final user.UserModel userData;
  final double discount;
  final bool isDelivery;
  final bool walletUsed;
  // final String prepTime;
  final double walletAmount;
  final String? deliveryInstruction;
  final Function prepTime;
  final String hubId;
  @override
  _OrderStateSelectorState createState() => _OrderStateSelectorState();
}

class _OrderStateSelectorState extends State<OrderStateSelector> {
  bool _isLoading = false;
  String? adtype;
  String? address2;
  String _deliveryAddress = '';
  int selectedMethod = 2; // 2 = online payment (Razorpay), 1 = COD
  bool driversAvailable = true;
  final PaymentTypeController paymentTypeController = PaymentTypeController();
  @override
  void initState() {
    super.initState();
    getAddressSelected();
    paymentTypeController.selectedPaymentMethod.addListener(() {
      selectedMethod = paymentTypeController.selectedPaymentMethod.value;
    });
  }

  // checkDriversAvailability() async {
  //   driversAvailable = ((await FirebaseFirestore.instance
  //                   .collection('hubs')
  //                   .doc(widget.hubId)
  //                   .get())
  //               .get('queue') ??
  //           [])
  //       .isNotEmpty;
  // }

  // Function to get the selected address type and details from SharedPreferences
  Future<void> getAddressSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _deliveryAddress = prefs.getString('CurrentAddress') ?? "";
    });
  }

  String generateUniqueId() {
    // Get today's date in DDMMYY format
    final String todayDate = DateFormat('ddMMyy').format(DateTime.now());

    // Keep the rest of the string structure intact
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Generate a 5-digit random string
    final String randomString =
        List.generate(5, (index) => Random().nextInt(10)).join();

    // Replace the first 6 digits of the timestamp with today's date
    final String updatedTimestamp = todayDate + timestamp.substring(6);

    // Return the formatted unique ID
    return '$updatedTimestamp-$randomString';
  }

  void orderNow() async {
    //Check for drivers availability
    if (widget.isDelivery && !driversAvailable) {
      final proceed = await showNoDriversAvailableDialog();
      if (proceed != true) {
        return;
      }
    }

    getAddressSelected();

    // Check if payment type is selected
    if (selectedMethod == -1) {
      Toast.showToast(message: 'Select a Payment Type', isError: true);
      return;
    }

    // Check minimum order cost
    if (widget.orderCost['order_value'].toDouble() < 70) {
      Toast.showToast(
          message:
              "Minimum cart Total should be greater than ₹ 70 to place order",
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // If cart is not empty, proceed with order placement
    if (widget.cartList.isNotEmpty) {
      var uniqueidorder = generateUniqueId();
      final orderModel = OrderModel(
        uid: SharedPrefsUtil().getString(AppStrings.userId) ?? '',
        orderData: OrderData(
            orderId: uniqueidorder,
            date: widget.selectedDate.toIso8601String(),
            time: widget.selectedTime.format(context),
            paymentMethod:
                selectedMethod == 1 ? 'Cash On Delivery' : 'Paid online',
            totalCost: widget.totalprice,
            gst: widget.orderCost['gst'],
            itemAmount: widget.orderCost['order_value'].toDouble(),
            deliveryCharge: widget.orderCost['delivery_fee'].toDouble(),
            convinenceFee: widget.orderCost['handling_charges'] +
                widget.orderCost['packing_charges'],
            orderByid: SharedPrefsUtil().getString(AppStrings.userId) ?? '',
            orderByName:
                SharedPrefsUtil().getString(AppStrings.userNameKey) ?? '',
            status: "Pending",
            deliveryAddress: widget.isDelivery
                ? _deliveryAddress
                : 'takeaway order Contact Customer',
            items: widget.cartList
                .map((e) => OrderItem(
                      itemId: e.itemId,
                      itemName: e.itemName,
                      itemQuantity: e.itemQuantity,
                      unitCost: e.unitCost,
                    ))
                .toList(),
            Restaurantuid: widget.restaurantuid,
            cookingDescription: widget.cookingreq ?? 'No request',
            drivertip: widget.drivertip ?? 0.0,
            couponcode: widget.code ?? "no code",
            timetoprepare: widget.prepTime(),
            ordertype: widget.isDelivery ? 'Delivery' : 'Takeaway',
            billingDetails: widget.orderCost),
      );

      // saveOrderDetails(uniqueidorder);
      // Process payment based on selected method
      if (kDebugMode) {
        // Bypass payment for testing
        if (widget.walletUsed && widget.walletAmount > 0) {
          WalletController.debit(widget.walletAmount, "for orderId : $uniqueidorder");
        }
        navigateToOrderProcessing(orderModel);
      } else if (selectedMethod == 1) {
        navigateToOrderProcessing(orderModel);
      } else {
        handleOnlinePayment(uniqueidorder, orderModel, widget.orderCost);
      }
    } else {
      Toast.showToast(message: 'Something went wrong!', isError: true);
    }

    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
  }

  // void saveOrderDetails(String orderId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  // }

  void handleOnlinePayment(
      String orderId, OrderModel orderModel, Map orderCost) async {
    if (widget.totalprice == 0) {
      if (widget.walletUsed && widget.walletAmount > 0) {
        WalletController.debit(widget.walletAmount, "for orderId : $orderId");
      }
      navigateToOrderProcessing(orderModel);
      return;
    }
    PaymentController payController = PaymentController(onSuccess: (txnId) {
      if (widget.walletUsed && widget.walletAmount > 0) {
        WalletController.debit(widget.walletAmount, "for orderId : $orderId");
      }
      // saveOrderDetails(orderId);
      navigateToOrderProcessing(orderModel, txnId: txnId);
    }, onFailure: () {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Payment Failed'),
        backgroundColor: Colors.red,
      ));
    });
    bool orderCreated = await payController.createOrder(
        amountInRupees: widget.totalprice.ceilToDouble());
    if (orderCreated) {
      await payController.initPayment(widget.totalprice.ceilToDouble());
    }
  }

  void navigateToOrderProcessing(OrderModel orderModel, {String? txnId}) {
    Navigator.of(context).pushReplacement(transitionToNextScreen(
      OrderProcessingScreen(
        user: widget.userData,
        orderModel: orderModel,
        deliveryInstruction: widget.deliveryInstruction,
        txnId: txnId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // _showScheduleOrderDialog(
                //     context, widget.selectedDate, widget.selectedTime);
                showComingSoon();
              },
              child: Container(
                width: 43.w,
                height: 5.h,
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 1.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/schedule_order_icon.svg',
                      height: 3.h,
                      color: primaryColor,
                    ),
                    Text(
                      'Schedule Order',
                      style: h6TextStyle.copyWith(
                          color: primaryColor, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: orderNow,
              child: Container(
                width: 35.w,
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 1.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: primaryColor,
                          )
                        : Text(
                            'Order Now',
                            style: h5TextStyle.copyWith(
                                color: isdarkmode ? textBlack : textWhite,
                                fontSize: 13.sp),
                          ),
                    SvgPicture.asset(
                      'assets/icons/order_now_icon.svg',
                      height: 2.h,
                      color: isdarkmode ? textBlack : textWhite,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
      ],
    );
  }

  void showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Coming Soon...",
                  style: h4TextStyle.copyWith(color: primaryColor)),
              const SizedBox(height: 10),
              Text(
                "This Feature will be avialable soon.",
                style: body4TextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future showNoDriversAvailableDialog() async {
    return await showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      "Our Delivery Partners are currently ocuupied!\nYou can place a preorder with a time limit, if none of our partners will be available within this time limit the order will get cancelled and refund will be initiated.",
                      textAlign: TextAlign.center,
                    )
                  ])),
            ));
  }

  // void _showScheduleOrderDialog(
  //   BuildContext context,
  //   DateTime date,
  //   TimeOfDay time,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         child: SingleChildScrollView(
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 color: const Color(0xfff7f7f7),
  //                 borderRadius: BorderRadius.circular(10)),
  //             padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
  //             child: Column(
  //               children: [
  //                 Container(
  //                   width: 100.w,
  //                   padding:
  //                       EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
  //                   margin: EdgeInsets.only(top: 2.h),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFf7f7f7),
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       color: textGrey2,
  //                       width: 0.2.h,
  //                     ),
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             'Select Date',
  //                             style: h5TextStyle,
  //                             maxLines: 1,
  //                             textAlign: TextAlign.start,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           const Spacer(),
  //                           GestureDetector(
  //                             onTap: () {
  //                               _selectDate(context, date);
  //                             },
  //                             child: const Icon(Icons.calendar_today),
  //                           ),
  //                         ],
  //                       ),
  //                       Center(
  //                         child: Text(
  //                           date.toString().split(' ')[0],
  //                           style: TextStyle(fontSize: 14.sp),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   width: 100.w,
  //                   padding:
  //                       EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
  //                   margin: EdgeInsets.symmetric(vertical: 2.h),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFf7f7f7),
  //                     borderRadius: BorderRadius.circular(10),
  //                     border: Border.all(
  //                       color: textGrey2,
  //                       width: 0.2.h,
  //                     ),
  //                   ),
  //                   child: Column(
  //                     children: [
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Text(
  //                             'Select Time',
  //                             style: h5TextStyle,
  //                             maxLines: 1,
  //                             textAlign: TextAlign.start,
  //                             overflow: TextOverflow.ellipsis,
  //                           ),
  //                           GestureDetector(
  //                             onTap: () {
  //                               _selectTime(context, date, time);
  //                             },
  //                             child: const Icon(Icons.access_time),
  //                           ),
  //                         ],
  //                       ),
  //                       Center(
  //                         child: Text(
  //                           time.format(context),
  //                           style: TextStyle(fontSize: 14.sp),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 5.w, vertical: 1.h),
  //                         decoration: BoxDecoration(
  //                           color: textWhite,
  //                           border: Border.all(
  //                             color: primaryColor,
  //                             width: 0.2.h,
  //                           ),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: Text(
  //                           'Cancel',
  //                           style: h6TextStyle.copyWith(color: primaryColor),
  //                         ),
  //                       ),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context); // Close the dialog
  //                         orderNow(); // Proceed with order
  //                       },
  //                       child: Container(
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 5.w, vertical: 1.h),
  //                         decoration: BoxDecoration(
  //                           color: primaryColor,
  //                           border: Border.all(
  //                             color: primaryColor,
  //                             width: 0.2.h,
  //                           ),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: Text(
  //                           'Confirm',
  //                           style: h6TextStyle.copyWith(color: textWhite),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // Future<void> _selectDate(BuildContext context, DateTime date) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: date,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(DateTime.now().year + 1),
  //     selectableDayPredicate: (DateTime date) {
  //       return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  //     },
  //   );
  //   if (pickedDate != null) {
  //     widget.onDateSelected(pickedDate);
  //   }
  // }

  // Future<void> _selectTime(
  //     BuildContext context, DateTime date, TimeOfDay selectedTime) async {
  //   final TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: selectedTime,
  //     builder: (BuildContext context, Widget? child) {
  //       return MediaQuery(
  //         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //         child: child!,
  //       );
  //     },
  //     helpText: 'Select Time',
  //     cancelText: 'Cancel',
  //     confirmText: 'Confirm',
  //     initialEntryMode: TimePickerEntryMode.dial,
  //   );

  //   if (pickedTime != null) {
  //     widget.onTimeSelected(pickedTime);
  //   }
  // }
}
