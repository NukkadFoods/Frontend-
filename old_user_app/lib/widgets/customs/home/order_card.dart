import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Orders/OrderTrackingScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

// class OngoingOrdersCards extends StatefulWidget {
//   const OngoingOrdersCards({
//     super.key,
//     required this.value,
//   });
//   final GlobalProvider value;
//   @override
//   State<OngoingOrdersCards> createState() => _OngoingOrdersCardsState();
// }

// class _OngoingOrdersCardsState extends State<OngoingOrdersCards>
//     with SingleTickerProviderStateMixin {
//   late GlobalProvider value;
//   late AnimationController controller;
//   late Animation<double> heightAnimate;
//   late Animation<double> paddingAnimate;
//   @override
//   void initState() {
//     value = widget.value;
//     super.initState();
//     controller = AnimationController(
//         duration: const Duration(milliseconds: 300), vsync: this);
//     heightAnimate = Tween<double>(begin: 0.5, end: 1)
//         .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
//     paddingAnimate = Tween<double>(begin: 1, end: 0)
//         .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
//   }

//   @override
//   Widget build(BuildContext context) {
//     int length = value.ongoingOrders.length;
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (value.showCarts && length > 1)
//             ElevatedButton(
//                 onPressed: () {
//                   if (!value.showCarts) {
//                     value.toggleShowCarts(!value.showCarts);
//                     // setState(() {});
//                     controller.forward();
//                   } else {
//                     controller.reverse().then((_) {
//                       value.toggleShowCarts(!value.showCarts);
//                       // setState(() {});
//                     });
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                     minimumSize: Size.zero,
//                     padding: const EdgeInsets.all(4),
//                     shape: const CircleBorder()),
//                 child: const Icon(Icons.close)),
//           Stack(
//             alignment: Alignment.topCenter,
//             children: [
//               for (int i = 0; i < value.ongoingOrders.length; i++)
//                 Container(
//                     margin: EdgeInsets.only(
//                         left: 4 * (length - i) * paddingAnimate.value,
//                         right: 4 * (length - i) * paddingAnimate.value,
//                         top: 6 * (length - i) * paddingAnimate.value +
//                             (value.showCarts ? 0 : 20)),
//                     height: value.height == null
//                         ? null
//                         : value.height! * (length - i) * heightAnimate.value,
//                     alignment: Alignment.bottomCenter,
//                     child: OrderCard(
//                       restaurant:
//                           value.restaurants!.restaurants!.firstWhere((res) {
//                         return res.id == value.ongoingOrders[i].Restaurantuid;
//                       }),
//                       order: value.ongoingOrders[i],
//                     )),
//               if (!value.showCarts && length > 1)
//                 ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 2),
//                         minimumSize: const Size.square(0)),
//                     onPressed: () {
//                       if (!value.showCarts) {
//                         value.toggleShowCarts(!value.showCarts);
//                         // setState(() {});
//                         controller.forward();
//                       } else {
//                         controller.reverse().then((_) {
//                           value.toggleShowCarts(!value.showCarts);
//                           // setState(() {});
//                         });
//                       }
//                     },
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text("+${length - 1} more"),
//                         const Icon(Icons.keyboard_arrow_up)
//                       ],
//                     )),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class OrderCard extends StatefulWidget {
  const OrderCard({super.key, required this.order});
  // final Restaurants restaurant;
  final Orders order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  Restaurants? restaurant;

  @override
  void initState() {
    super.initState();
    getRestaurant();
  }

  void getRestaurant() async {
    final restaurantList = context
        .read<GlobalProvider>()
        .restaurants!
        .restaurants!
        .where((res) => res.id == widget.order.Restaurantuid);
    if (restaurantList.isNotEmpty) {
      restaurant = restaurantList.first;
    } else {
      try {
        final response = await http.post(
          Uri.parse(
              '${AppStrings.baseURL}/auth/getRestaurantUser/${widget.order.Restaurantuid}'),
        );

        if (response.statusCode == 200) {
          var res = jsonDecode(response.body);
          if (res['executed']) {
            restaurant = Restaurants.fromJson(res['user']);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return restaurant == null
        ? const SizedBox.shrink()
        : Card.filled(
            elevation: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(1.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        clipBehavior: Clip.hardEdge,
                        child: restaurant!.restaurantImages!.isEmpty
                            ? Image.asset(
                                'assets/images/restaurantImage.png',
                                fit: BoxFit.cover,
                                height: 5.5.h,
                                width: 5.5.h,
                              )
                            : CachedNetworkImage(
                                fit: BoxFit.cover,
                                height: 5.5.h,
                                width: 5.5.h,
                                imageUrl: restaurant!.restaurantImages![0],
                                placeholder: (context, url) => Image.asset(
                                      'assets/images/restaurantImage.png',
                                      fit: BoxFit.cover,
                                    )),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              restaurant!.nukkadName!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          // Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          Text("Your Order is ${widget.order.status}"),
                          // const Icon(Icons.arrow_right)
                          //   ],
                          // )
                        ])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(transitionToNextScreen(
                            OrderTrackingScreen(
                                isDelivery:
                                    widget.order.ordertype == "Delivery",
                                nukkad: restaurant!,
                                Amount: widget.order.totalCost.toString(),
                                orderid: widget.order.orderId!,
                                // Status: order.status!,
                                time: widget.order.time!,
                                deliveryTime:
                                    DateTime.parse(widget.order.timetoprepare!),
                                orderedAt:
                                    DateTime.parse(widget.order.date!))));
                      },
                      style: const ButtonStyle().copyWith(
                          backgroundColor:
                              const WidgetStatePropertyAll(primaryColor),
                          padding:
                              const WidgetStatePropertyAll(EdgeInsets.all(2)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)))),
                      child: const Text("Track\nOrder",
                          style: TextStyle(color: Colors.white))),
                ),
              ],
            ),
          );
  }
}
