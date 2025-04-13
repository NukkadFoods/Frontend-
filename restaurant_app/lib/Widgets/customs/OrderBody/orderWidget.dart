import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/Controller/earnings_controller.dart';
import 'package:restaurant_app/Controller/order/order_controller.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Controller/order/update_order_response_model.dart';
import 'package:restaurant_app/Screens/Navbar/orderBody.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/show_snack_bar_extension.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/HomeBody/viewTotalBill.dart';
import 'package:restaurant_app/Widgets/customs/OrderBody/takeaway.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:sizer/sizer.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';

import '../../../Screens/Orders/trackRiderScreen.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget(
      {super.key,
      required this.type,
      required this.onOrdersRefresh,
      required this.order,
      required this.nukkad});

  final bool type;
  final Orders? order;
  final OrdersRefreshCallback onOrdersRefresh;
  final User nukkad;

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool isDeclined = false;
  bool isAccepted = false;
  bool isPrepared = false;
  bool isMarkedReady = false;
  List<dynamic> items = [];
  bool isEditLoading = false;
  String? orderId;
  String? uid;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    if (widget.order != null) {
      // Initialize items only if widget.order is not null
      items = widget.order!.orderData!.items ?? [];
      orderId = widget.order!.orderData!.orderId;
      uid = widget.order!.uid!;
      // uid = widget.uid;
    } else {
      items = [];
    }
    // print(widget.order!.orderData!.billingDetail!['latePrep']);
    super.initState();
  }

  Future<void> orderDeleted() async {
    final proceed = await showDeclineWarning(
        context,
        ((widget.order!.orderData!.billingDetail!['nukkad_earning'].toDouble()
                    as double) *
                .10)
            .clamp(0, 25)
            .toDouble()
            .roundOff());
    if (proceed != true) {
      return;
    }
    setState(() {
      isEditLoading = true;
    });
    var result = await OrderController.updateOrder(
      uid: uid!,
      orderId: orderId!,
      status: "Declined",
      context: context,
    );
    result.fold((errorMessage) {
      setState(() {
        isEditLoading = false;
      });
      context.showSnackBar(message: errorMessage);
    }, (UpdateOrderResponseModel updateOrderResponseModel) async {
      await EarningsController.addEarning(
          uid: SharedPrefsUtil().getString(AppStrings.userId)!,
          orderId: widget.order!.orderData!.orderId!,
          userId: widget.order!.orderData!.orderByid!,
          amount: -((widget.order!.orderData!.billingDetail!['nukkad_earning']
                      .toDouble() as double) *
                  .10)
              .clamp(0, 25)
              .toDouble()
              .roundOff());
      // widget.order = updateOrderResponseModel.order;
      widget.onOrdersRefresh();
      isEditLoading = false;
      isDeclined = true;
      isAccepted = false;
      isPrepared = false;
      isMarkedReady = false;
      if (mounted) {
        setState(() {});
      }
      widget.onOrdersRefresh();
      context.showSnackBar(message: updateOrderResponseModel.message!);
    });
  }

  Future<void> markReady() async {
    setState(() {
      isEditLoading = true;
    });

    var result = await OrderController.updateOrder(
      billingDetail: widget.order!.orderData!.billingDetail,
      uid: uid!,
      orderId: orderId!,
      status: "Ready",
      context: context,
    );
    result.fold((errorMessage) {
      setState(() {
        isEditLoading = false;
      });
      context.showSnackBar(message: errorMessage);
    }, (UpdateOrderResponseModel updateOrderResponseModel) {
      print(updateOrderResponseModel.order!.orderData!.status!);
      setState(() {
        // widget.order = updateOrderResponseModel.order;
        widget.onOrdersRefresh();
        isDeclined = false;
        isAccepted = true;
        isPrepared = true;
        isMarkedReady = true;
        isEditLoading = false;
      });
      context.showSnackBar(message: updateOrderResponseModel.message!);
    });
  }

  Future<void> startPreparing() async {
    setState(() {
      isEditLoading = true;
    });

    await OrderController.updateOrder(
      uid: uid!,
      orderId: orderId!,
      status: "Preparing",
      context: context,
    ).then((value) {
      setState(() {
        // widget.order = updateOrderResponseModel.order;
        widget.onOrdersRefresh();
        isDeclined = false;
        isAccepted = true;
        isEditLoading = false;
        isPrepared = true;
        isMarkedReady = false;
      });
    }).catchError((error) {
      setState(() {
        isEditLoading = false;
      });
      context.showSnackBar(message: error.toString());
    });
  }

  Future<void> acceptOrder() async {
    setState(() {
      isEditLoading = true;
    });

    await OrderController.updateOrder(
      uid: uid!,
      orderId: orderId!,
      status: "Accepted",
      context: context,
    ).then((value) {
      setState(() {
        widget.onOrdersRefresh();
        isDeclined = false;
        isAccepted = true;
        isPrepared = false;
        isMarkedReady = false;
        isEditLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isEditLoading = false;
      });
      context.showSnackBar(message: error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    bool type = widget.type;
    return isEditLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          )
        : Container(
            padding: EdgeInsets.only(top: 2.h),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: textWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: textGrey3, width: 0.2.h),
                  boxShadow: [
                    BoxShadow(
                      color: textGrey3.withOpacity(0.5), // Shadow color
                      spreadRadius: 2, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 3), // Offset in the x and y directions
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                // "ID: #${widget.order!['orderId'] != null ? widget.order!['orderId'] : 0}",
                                "ID: #${widget.order!.orderData!.orderId ?? 0}",
                                style: body4TextStyle.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 3.w, vertical: 0.2.h),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  // widget.order!['status'] != null
                                  //     ? widget.order!['status']
                                  widget.order!.orderData!.status ?? '',
                                  style: body4TextStyle.copyWith(
                                      color: textWhite,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 35.w,
                                padding: EdgeInsets.symmetric(vertical: 0.4.h),
                                child: Text(
                                  // 'Today, ${widget.order!['time'] != null ? widget.order!['time'] : ''}',
                                  '${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.order!.orderData!.date!.substring(0, widget.order!.orderData!.date!.length - 1)))}, ${widget.order!.orderData!.time ?? ''}',
                                  style:
                                      body5TextStyle.copyWith(color: textGrey2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                width: 48.w,
                                padding: EdgeInsets.symmetric(vertical: 0.4.h),
                                child: Text(
                                  'By ${widget.order!.orderData!.orderByName ?? ''}',
                                  style:
                                      body5TextStyle.copyWith(color: textGrey2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 35.w,
                                padding: EdgeInsets.symmetric(vertical: 0.4.h),
                                child: Text(
                                  'Order total : ₹${(widget.order!.orderData!.billingDetail!['nukkad_earning'] - (widget.order!.orderData!.billingDetail!['discount'] ?? 0)).toDouble().toStringAsFixed(2)}',
                                  style: body5TextStyle.copyWith(
                                    color: textBlack,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: colorSuccess, width: 0.2.h),
                                  color: textGrey2,
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 0.2.h, horizontal: 3.w),
                                child: Text(
                                  widget.order!.orderData!.ordertype.toString(),
                                  style: body5TextStyle.copyWith(
                                      color: textBlack,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: textGrey2,
                            thickness: 0.2.h,
                          ),
                          SizedBox(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return _buildOrderDetailsWidget(items[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((widget.order!.orderData!.cookingDescription ?? '')
                        .isNotEmpty)
                      Container(
                        width: double.maxFinite,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: primaryColor),
                            color: Colors.grey[100]),
                        child: RichText(
                            text: TextSpan(children: [
                          const TextSpan(
                              text: "Description: ",
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600)),
                          TextSpan(
                              text: widget.order!.orderData!.cookingDescription,
                              style: TextStyle(color: Colors.black))
                        ])),
                      ),
                    type
                        ? _buildOrderStatusWidget()
                        : widget.order!.orderData!.status == 'Declined' ||
                                widget.order!.orderData!.status == "Canceled"
                            ? _buildOrderStatusWidget()
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewTotalBillWidget(
                                              order: widget.order!,
                                            )),
                                  );
                                  // ViewTotalBillWidget
                                },
                                child: Container(
                                  height: 6.h,
                                  width: 100.w,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 1.h),
                                  decoration: const BoxDecoration(
                                    color: textGrey1,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(9),
                                      bottomRight: Radius.circular(9),
                                    ),
                                  ),
                                  child: Text(
                                    'View Reciept',
                                    style:
                                        h5TextStyle.copyWith(color: textWhite),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildOrderStatusWidget() {
    if (widget.order!.orderData!.status == 'Canceled' ||
        widget.order!.orderData!.status == 'Declined') {
      return _buildDeclinedWidget();
    } else if (widget.order!.orderData!.status == 'Pending') {
      return _buildPendingWidget();
    } else if (widget.order!.orderData!.status == 'Accepted') {
      return _buildPreparedWidget();
    } else if (widget.order!.orderData!.status == 'Preparing') {
      return _buildMarkReadyWidget();
    } else {
      return _buildTrackRideWidget();
    }
    // if (widget.order!['status'] == 'Canceled') {
    //   return _buildDeclinedWidget();
    // } else if (widget.order!['status'] == 'Pending') {
    //   return _buildPendingWidget();
    // } else if ((widget.order!['status'] == 'Accepted')) {
    //   return _buildPreparedWidget();
    // } else if (widget.order!['status'] == 'Ready') {
    //   return _buildMarkReadyWidget();
    // } else {
    //   return _buildTrackRideWidget();
    // }
  }

  Widget _buildOrderDetailsWidget(Items item) {
    return SizedBox(
      width: 45.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${item.itemQuantity} x',
            style: body4TextStyle,
          ),
          SizedBox(width: 6.w),
          Text(
            '${item.itemName}',
            style: body4TextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDeclinedWidget() {
    return Container(
      height: 6.h,
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: const BoxDecoration(
        color: colorFailure,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
      ),
      child: Text(
        'Declined',
        style: h5TextStyle.copyWith(color: textWhite),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPendingWidget() {
    return SizedBox(
      height: 6.h,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              orderDeleted();
              db
                  .collection('tracking')
                  .doc(widget.order!.orderData!.orderId)
                  .update({'acceptedByRestaurant': false});
            },
            child: Container(
              height: 6.h,
              width: 44.6.w,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: const BoxDecoration(
                color: textGrey1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                ),
              ),
              child: Text(
                'Decline',
                style: h5TextStyle.copyWith(color: textWhite),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              db.runTransaction((transaction) async {
                transaction.update(
                    db
                        .collection('tracking')
                        .doc(widget.order!.orderData!.orderId),
                    {'acceptedByRestaurant': true});
              });
              acceptOrder();
              // await controller.getAllDeliveryBoys();
              // controller.assignDboy();
            },
            child: Container(
              height: 6.h,
              width: 44.5.w,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: const BoxDecoration(
                color: colorSuccess,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(9),
                ),
              ),
              child: Text(
                'Accept',
                style: h5TextStyle.copyWith(color: textWhite),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparedWidget() {
    return GestureDetector(
      onTap: () {
        startPreparing();
      },
      child: Container(
        height: 6.h,
        width: 100.w,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(9),
            bottomRight: Radius.circular(9),
          ),
        ),
        child: Text(
          'Start Preparing',
          style: h5TextStyle.copyWith(color: textWhite),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMarkReadyWidget() {
    return SizedBox(
      height: 6.h,
      child: Row(
        children: [
          if (widget.order!.orderData!.ordertype == 'Delivery')
            GestureDetector(
              onTap: () async {
                if ((await db
                        .collection('tracking')
                        .doc(orderId!)
                        .get())['dBoyId'] !=
                    "unassigned") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrackRiderScreen(
                                orderId: orderId!,
                              )));
                } else {
                  Toast.showToast(message: 'DBoy not assigned yet');
                }
              },
              child: Container(
                height: 6.h,
                width: 44.6.w,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: textWhite,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(9),
                  ),
                  border: Border.all(color: primaryColor, width: 0.2.h),
                ),
                child: Text(
                  'Track Rider',
                  style: h5TextStyle.copyWith(color: primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          GestureDetector(
            onTap: () {
              markReady();
            },
            child: Container(
              height: 6.h,
              width: widget.order!.orderData!.ordertype == 'Delivery'
                  ? 44.5.w
                  : 89.w,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(9),
                    bottomLeft: Radius.circular(
                        widget.order!.orderData!.ordertype == 'Delivery'
                            ? 0
                            : 9)),
              ),
              child: Text(
                'Mark Ready',
                style: h5TextStyle.copyWith(color: textWhite),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackRideWidget() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              if (widget.order!.orderData!.ordertype == 'Delivery') {
                if ((await db
                        .collection('tracking')
                        .doc(orderId!)
                        .get())['dBoyId'] !=
                    "unassigned") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrackRiderScreen(
                                orderId: orderId!,
                              )));
                } else {
                  Toast.showToast(message: 'DBoy not assigned yet.');
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => TrackRiderScreen(
                //       orderId: orderId!,
                //     ),
                //   ),
                // );
              } else {
                final completed = await Navigator.of(context).push(
                    transitionToNextScreen(
                        TakeawayScreen(orderData: widget.order!.orderData!)));
                if (completed == true) {
                  widget.onOrdersRefresh();
                }
              }
            },
            child: Container(
              alignment: Alignment.center,
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight:
                      widget.order!.orderData!.ordertype == 'Delivery' &&
                              widget.order!.orderData!.status != "On the way"
                          ? Radius.zero
                          : Radius.circular(9),
                ),
              ),
              child: Text(
                widget.order!.orderData!.ordertype == 'Delivery'
                    ? 'Track Rider'
                    : "Complete Takeaway Order",
                style: h5TextStyle.copyWith(color: textWhite),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (widget.order!.orderData!.ordertype == 'Delivery' &&
            widget.order!.orderData!.status != "On the way")
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final completed = await Navigator.of(context).push(
                    transitionToNextScreen(
                        TakeawayScreen(orderData: widget.order!.orderData!)));
                if (completed == true) {
                  print(completed.toString());
                  widget.onOrdersRefresh();
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 6.h,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: textGrey1,
                  borderRadius: BorderRadius.only(
                    bottomLeft: widget.order!.orderData!.ordertype == 'Delivery'
                        ? Radius.zero
                        : Radius.circular(9),
                    bottomRight: Radius.circular(9),
                  ),
                ),
                child: Text(
                  'Handover',
                  style: h5TextStyle.copyWith(color: textWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future showDeclineWarning(BuildContext context, double amount) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "\nDeclining the order will result a penalty of ",
                style: TextStyle(color: Colors.black, fontSize: 13),
                children: [
                  TextSpan(
                      text: '₹ $amount ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const TextSpan(text: 'on you.\nDo you want to proceed?'),
                ])),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(primaryColor)),
              child: const Text("Yes", style: TextStyle(color: Colors.white))),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"))
        ],
      ),
    );
  }
}
