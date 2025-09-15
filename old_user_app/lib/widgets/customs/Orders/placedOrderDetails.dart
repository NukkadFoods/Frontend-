import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Orders/OrderTrackingScreen.dart';
import 'package:user_app/screens/Orders/orderSummary.dart';

import 'dart:convert'; // Make sure to import this
import 'package:http/http.dart' as http;
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class PlacedOrderDetails extends StatefulWidget {
  final bool isOngoing;
  final BuildContext context;
  final Orders order;

  const PlacedOrderDetails({
    super.key,
    required this.isOngoing,
    required this.context,
    required this.order,
  });

  @override
  _PlacedOrderDetailsState createState() => _PlacedOrderDetailsState();
}

class _PlacedOrderDetailsState extends State<PlacedOrderDetails> {
  Restaurants? nukkad;
  Map? orderCost;
  bool errorOccured = false;
  @override
  void initState() {
    super.initState();
    getres();
  }

  Future<void> getres() async {
    if (context.read<GlobalProvider>().restaurants != null) {
      final nukkadList =
          context.read<GlobalProvider>().restaurants!.restaurants!.where((res) {
        return res.id == widget.order.Restaurantuid;
      });
      if (nukkadList.isNotEmpty) {
        nukkad = nukkadList.first;
      }
    }
    if (nukkad == null) {
      final response = await http.post(
        Uri.parse(
            '${AppStrings.baseURL}/auth/getRestaurantUser/${widget.order.Restaurantuid}'),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['executed']) {
          var user = res['user'];
          nukkad = Restaurants.fromJson(user);
        } else {
          errorOccured = true;
        }
      } else {
        errorOccured = true;
      }
      if (mounted) {
        setState(() {});
      }
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;

    // Check for null values and show CircularProgressIndicator if any data is missing
    if (nukkad == null && !errorOccured) {
      return Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    } else if (nukkad == null && errorOccured) {
      return const SizedBox.shrink();
    }
    double total = widget.order.totalCost!.toDouble();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            transitionToNextScreen(
              OrderSummary(
                isOngoing: widget.isOngoing,
                order: widget.order,
                nukkad: nukkad!,
              ),
            ),
          );
        },
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // width: 100.w,
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 0.2.h, color: textGrey3),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          bottom: BorderSide(width: 0.2.h, color: textGrey3),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: NetworkImageWidget(
                              imageUrl: nukkad!.restaurantImages!.isEmpty
                                  ? ""
                                  : nukkad!.restaurantImages![0],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${nukkad!.nukkadName}",
                                    style: h5TextStyle.copyWith(
                                        color:
                                            isdarkmode ? textGrey2 : textBlack),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    '${nukkad!.nukkadAddress}',
                                    style: body5TextStyle.copyWith(
                                      color: textGrey2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 1.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/timer_icon.svg',
                                          height: 3.h,
                                          color: primaryColor,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          '${(int.tryParse(nukkad!.timetoprepare!.toString()) ?? 0) + 15}',
                                          style: body5TextStyle.copyWith(
                                              color: isdarkmode
                                                  ? textGrey2
                                                  : textBlack),
                                        ),
                                        SvgPicture.asset(
                                          'assets/icons/dot.svg',
                                          height: 2.h,
                                          color: textGrey1,
                                        ),
                                        Text(
                                          '${nukkad!.getAverageRating().toStringAsFixed(1)}',
                                          style: body5TextStyle.copyWith(
                                              color: isdarkmode
                                                  ? textGrey2
                                                  : textBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: Container(
                        height: 3.5.h,
                        width: 25.w,
                        decoration: BoxDecoration(
                            color: widget.isOngoing ? Colors.green : textGrey2,
                            borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              widget.isOngoing
                                  ? 'assets/icons/preparing_icon.svg'
                                  : 'assets/icons/delivered_icon.svg',
                              height: widget.isOngoing ? 2.h : 2.h,
                              color: isdarkmode ? textBlack : Colors.white,
                            ),
                            Text(
                              // isOngoing ? 'Preparing' : 'Delivered',
                              widget.order.status ??
                                  (widget.isOngoing
                                      ? 'Preparing'
                                      : 'delivered'),
                              style: body5TextStyle.copyWith(
                                color: isdarkmode ? textBlack : textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.order.items?.isNotEmpty ?? false
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.order.items!.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) => Text(
                                    '${widget.order.items![index].itemQuantity} x ${widget.order.items![index].itemName}',
                                    style: body4TextStyle.copyWith(
                                        color:
                                            isdarkmode ? textGrey2 : textBlack),
                                  ))
                          : const SizedBox.shrink(),
                      // Text('1 x Fried Rice', style: body4TextStyle),
                      // Text('1 x Schezwan Noodles', style: body4TextStyle),
                      Divider(
                        thickness: 0.2.h,
                        color: textGrey3,
                        endIndent: 35.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          children: [
                            Text(
                              'Total',
                              style: body5TextStyle.copyWith(
                                  color: isdarkmode ? textGrey2 : textBlack),
                            ),
                            const Spacer(),
                            const Spacer(),
                            Text(
                              '₹ ${total.toStringAsFixed(2)} ',
                              style: h6TextStyle.copyWith(
                                  color: isdarkmode ? textGrey2 : textBlack),
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                      DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 0.2.h,
                        dashLength: 2.5.w,
                        dashColor: textGrey2,
                        dashGapLength: 1.w,
                        dashGapColor: Colors.transparent,
                      ),
                      Container(
                        height: 6.5.h,
                        padding: EdgeInsets.only(top: 1.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isOngoing
                                      ? 'Estimated delivery in 1 hr'
                                      : 'Delivered',
                                  style: body4TextStyle.copyWith(
                                    fontSize: 11.sp,
                                    color: textGrey2,
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              color: primaryColor,
                              child: GestureDetector(
                                onTap: () async {
                                  widget.isOngoing
                                      ?
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> Liveordertracking(orderid: widget.order.orderId ?? ''))) :{};
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderTrackingScreen(
                                                    nukkad: nukkad!,
                                                    Amount: widget
                                                        .order.totalCost
                                                        .toString(),
                                                    orderid:
                                                        widget.order.orderId!,
                                                    // Status:
                                                    //     widget.order.status!,
                                                    time: widget.order.time!,
                                                    deliveryTime:
                                                        DateTime.tryParse(widget
                                                            .order
                                                            .timetoprepare!)!,
                                                    orderedAt: DateTime.parse(
                                                        widget.order.date!),
                                                    isDelivery: widget
                                                            .order.ordertype ==
                                                        "Delivery",
                                                  )))
                                      : {
                                          Navigator.of(context).push(
                                              transitionToNextScreen(
                                                  RestaurantScreen(
                                                      restaurantID: widget
                                                          .order.Restaurantuid!,
                                                      isFavourite: false,
                                                      restaurantName:
                                                          nukkad!.nukkadName!,
                                                      res: nukkad!)))
                                        };
                                },
                                child: Container(
                                  height: 3.5.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        widget.isOngoing
                                            ? 'assets/icons/track_order_icon.svg'
                                            : 'assets/icons/repeat_order_icon.svg',
                                        color: isdarkmode
                                            ? textBlack
                                            : Colors.white,
                                        height: 2.5.h,
                                      ),
                                      Text(
                                        widget.isOngoing
                                            ? 'Track Order'
                                            : 'Reorder',
                                        style: body4TextStyle.copyWith(
                                            color: isdarkmode
                                                ? textBlack
                                                : textWhite),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
