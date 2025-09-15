import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/Screens/Support/feedbackScreen.dart';
import 'package:user_app/Screens/Support/helpSupportScreen.dart';
import 'package:user_app/screens/Support/complaintsScreen.dart';
import 'package:user_app/widgets/buttons/ratingButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Cart/cartbill.dart';
import 'package:user_app/widgets/customs/Cart/effectivebill.dart';
import 'package:user_app/widgets/customs/Cart/savingsWidget.dart';
import 'package:http/http.dart' as http;

class OrderSummary extends StatefulWidget {
  final bool isOngoing;
  final Orders order;
  final Restaurants nukkad;
  const OrderSummary({
    super.key,
    required this.isOngoing,
    required this.nukkad,
    required this.order,
  });

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  var ratings;
  bool isLoading = true;
  double distanceInKm = 0;
  @override
  void initState() {
    super.initState();
    getOrderCost();
  }

  void getOrderCost() async {
    orderCost = widget.order.billingDetail!;
    final orderDoc = (await FirebaseFirestore.instance
            .collection('tracking')
            .doc(widget.order.orderId)
            .get())
        .data()!;
    distanceInKm = Geolocator.distanceBetween(
            widget.nukkad.latitude!.toDouble(),
            widget.nukkad.longitude!.toDouble(),
            orderDoc['userLat'].toDouble(),
            orderDoc['userLng'].toDouble()) /
        1000;
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> rateRestaurant(String restaurantId, double rating) async {
    final url = Uri.parse('${AppStrings.baseURL}/auth/rateRestaurantById');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'id': restaurantId,
      'rating': rating.toString(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Order Ratings Submitted ..!!',
            backgroundColor: textWhite,
            textColor: colorSuccess,
            gravity: ToastGravity.CENTER);
      } else {
        print('Failed to submit rating. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  void showComplaintBottomSheet(BuildContext context, String restaurantId,
      {required orderid}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled:
          true, // Allows the modal to take up more space when keyboard is up
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: RateAndComplaintPage(
            restaurantId: restaurantId,
            orderid: orderid,
          ),
        );
      },
    );
  }

  late Map orderCost;
  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    bool isOngoing = widget.isOngoing;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios,
              color: isdarkmode ? textGrey2 : textBlack),
        ),
        title: Text(
          'Order Summary',
          style:
              h5TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () {
                showComplaintBottomSheet(context, widget.order.Restaurantuid!,
                    orderid: widget.order.orderId);
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/background.png',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10.h,
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50.w,
                                child: Text(
                                  '${widget.nukkad.nukkadName}',
                                  style:
                                      h5TextStyle.copyWith(color: primaryColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                height: 3.5.h,
                                decoration: BoxDecoration(
                                    color: isOngoing ? Colors.green : textGrey2,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      isOngoing
                                          ? 'assets/icons/preparing_icon.svg'
                                          : 'assets/icons/delivered_icon.svg',
                                      height: isOngoing ? 3.h : 2.h,
                                      color:
                                          isdarkmode ? textBlack : Colors.white,
                                    ),
                                    Text(
                                      widget.order.status ??
                                          (widget.isOngoing
                                              ? 'Preparing'
                                              : 'delivered'),
                                      style: body6TextStyle.copyWith(
                                          color: isdarkmode
                                              ? textBlack
                                              : textWhite),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              '${widget.nukkad.nukkadAddress}',
                              style: body5TextStyle.copyWith(
                                  color: isdarkmode ? textGrey2 : textBlack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 90.w,
                            child: Text(
                              'Order Number #${widget.order.orderId ?? 0}',
                              style: body5TextStyle.copyWith(
                                  color: isdarkmode ? textGrey2 : textBlack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${DateFormat("dd/MM/yyyy").format(DateTime.parse(widget.order.date!))}, ${widget.order.time}',
                            style: body5TextStyle.copyWith(
                                color: isdarkmode ? textGrey2 : textBlack),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildDividerWidget(),
                    _buildOrderWidget(isdarkmode),
                    _buildDividerWidget(),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                      // Ensure the value is not null and cast to int.
                      // child: detailedBill(context, widget.order),
                      child: CartBill(
                        context,
                        orderCost,
                        orderCost['discount'] ?? 0,
                        distanceInKm,
                        cartModelList: List<CartModel>.generate(
                            widget.order.items!.length,
                            (int i) => CartModel(
                                restaurantId: widget.nukkad.id!,
                                itemId: widget.order.items![i].itemId!,
                                itemName: widget.order.items![i].itemName!,
                                itemQuantity: widget
                                    .order.items![i].itemQuantity!
                                    .toInt(),
                                unitCost:
                                    widget.order.items![i].unitCost!.toDouble(),
                                type: '',
                                timetoprepare:
                                    widget.order.items![i].unitCost!)),
                        walletCashUsed: orderCost['walletCashUsed'],
                        isDelivery: widget.order.ordertype == "Delivery",
                      ),
                    ),
                    _buildTotalCostWidget(isdarkmode),
                    EffectiveBillWidget(
                        orderCost: orderCost, order: widget.order),
                    if (orderCost['latePrep'] == true ||
                        orderCost['lateDelivery'] == true)
                      SavingsWidget(isdarkmode, orderCost),
                    SizedBox(
                      height: 2.h,
                    ),
                    _buildRateOrderWidget(isdarkmode),
                  ],
                ),
              ),
            ]),
    );
  }

  Widget _buildOrderWidget(bool isdarkmode) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Order',
                  style: h5TextStyle.copyWith(color: primaryColor),
                ),
                SizedBox(height: 2.h),
                widget.order.items!.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemCount: widget.order.items!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCustomTextWidget(
                                      isdarkmode,
                                      text:
                                          '${widget.order.items![index].itemQuantity} x ${widget.order.items![index].itemName}',
                                    ),
                                    _buildCustomTextWidget(
                                      isdarkmode,
                                      text:
                                          '1 x ₹${widget.order.items![index].unitCost}',
                                      style: body5TextStyle.copyWith(
                                          color: textGrey2),
                                    ),
                                  ]),
                            ),
                            _buildCustomTextWidget(isdarkmode,
                                flex: 0,
                                text:
                                    '₹ ${widget.order.items![index].itemQuantity != null && widget.order.items![index].unitCost != null ? (widget.order.items![index].itemQuantity! * widget.order.items![index].unitCost!) : "0.0"}'),
                          ],
                        ),
                        separatorBuilder: (context, index) => SizedBox(
                          height: 2.h,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            // _buildDividerWidget(),
            Divider(
              color: textGrey2,
              thickness: 0.2.h,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child:
                            _buildCustomTextWidget(isdarkmode, text: 'Taxes')),
                    _buildCustomTextWidget(isdarkmode,
                        flex: 0,
                        text:
                            '₹ ${widget.order.gst != null && widget.order.convinenceFee != null ? (widget.order.gst! + widget.order.convinenceFee!).toStringAsFixed(2) : 0.0}'),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCustomTextWidget(isdarkmode,
                              text: 'Delivery Fee'),
                          // Text(
                          //   'Delivery Fee',
                          //   style: h6TextStyle,
                          // ),
                          _buildCustomTextWidget(isdarkmode,
                              text:
                                  'For ${distanceInKm < 1 ? "0.5-0.9" : distanceInKm.toStringAsFixed(2)} KM',
                              style: body5TextStyle.copyWith(color: textGrey2)),
                        ],
                      ),
                    ),
                    _buildCustomTextWidget(isdarkmode,
                        flex: 0,
                        text:
                            '₹ ${(orderCost['delivery_fee'] + orderCost['shortValueOrder'] + orderCost['longDistanceCharge']) ?? 0.0}'),
                    // Text(
                    //   '₹ ${widget.order.deliveryCharge ?? 0.0}',
                    //   style: h6TextStyle,
                    // ),
                  ],
                ),
                if (orderCost['walletCashUsed'] != null &&
                    orderCost['walletCashUsed'] > 0)
                  SizedBox(height: 1.h),
                if (orderCost['walletCashUsed'] != null &&
                    orderCost['walletCashUsed'] > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _buildCustomTextWidget(isdarkmode,
                              text: 'Wallet Cash Used')),
                      _buildCustomTextWidget(isdarkmode,
                          flex: 0,
                          text:
                              '₹ ${orderCost['walletCashUsed'].toStringAsFixed(2)}'),
                    ],
                  ),
                if (orderCost['discount'] != null && orderCost['discount'] > 0)
                  SizedBox(height: 1.h),
                if (orderCost['discount'] != null && orderCost['discount'] > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _buildCustomTextWidget(isdarkmode,
                              text: 'Discount')),
                      _buildCustomTextWidget(isdarkmode,
                          flex: 0,
                          text:
                              '- ₹ ${orderCost['discount'].toStringAsFixed(2)}'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _buildTotalCostWidget(bool isdarkmode) => Container(
        height: 6.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 63, 164, 4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorSuccess),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Grand Total',
              style: h5TextStyle.copyWith(
                  color: isdarkmode ? textBlack : textWhite),
            ),
            Text(
              '₹ ${(orderCost['total'] - (orderCost['discount'] ?? 0) - (orderCost['walletCashUsed'] ?? 0)).toStringAsFixed(2)}',
              style: h5TextStyle.copyWith(
                  color: isdarkmode ? textBlack : textWhite),
            ),
          ],
        ),
      );

  Widget _buildRateOrderWidget(bool isdarkmode) => Container(
        // height: 21.h,
        width: 90.w,
        margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
        decoration: BoxDecoration(
            color:
                isdarkmode ? const Color.fromARGB(255, 34, 32, 32) : textWhite,
            border: Border.all(
              color: textGrey2,
              width: 0.2.h,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 1.6.h,
            ),
            Text('Rate Your Order',
                style: h5TextStyle.copyWith(
                    color: isdarkmode ? textGrey2 : textBlack)),
            Text(
              'From ${widget.nukkad.nukkadName}',
              style: body4TextStyle.copyWith(color: textGrey2),
            ),
            SizedBox(height: 1.h),
            ratingButton(
              onRatingSelected: (rating) {
                rateRestaurant(widget.order.Restaurantuid!, rating);
                print('Selected Rating: $ratings');
                // You can also use the rating here, e.g., save it to a database or state
              },
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                        restaurantname: '${widget.nukkad.nukkadName}',
                        order: widget.order),
                  ),
                );
              },
              child: Text('Tell Us More',
                  style: h6TextStyle.copyWith(color: primaryColor)),
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                  Colors.transparent,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
              child: Text(
                'Need help with the orders?',
                style: h6TextStyle.copyWith(color: primaryColor),
              ),
            ),
          ],
        ),
      );

  Widget _buildDividerWidget() => Divider(
        color: textGrey2,
        thickness: 0.2.h,
        endIndent: 5.w,
        indent: 5.w,
      );

  Widget _buildCustomTextWidget(
    bool isdarkmode, {
    required String text,
    TextStyle? style,
    int? flex,
  }) =>
      Row(
        children: [
          Expanded(
            flex: flex ?? 1,
            child: Text(
              text,
              style: style ??
                  h6TextStyle.copyWith(
                      color: isdarkmode ? textGrey2 : textBlack),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}
