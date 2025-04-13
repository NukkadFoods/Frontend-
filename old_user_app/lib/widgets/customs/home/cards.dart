import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Restaurant/cartScreen.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/screens/registerScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/customs/home/order_card.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/toasts.dart';

import '../../../Controller/food/model/cart_model.dart';

class StackedCarts extends StatefulWidget {
  const StackedCarts({
    super.key,
    required this.value,
  });
  final GlobalProvider value;
  @override
  State<StackedCarts> createState() => _StackedCartsState();
}

class _StackedCartsState extends State<StackedCarts>
    with SingleTickerProviderStateMixin {
  late GlobalProvider value;
  late AnimationController controller;
  late Animation<double> heightAnimate;
  late Animation<double> paddingAnimate;
  @override
  void initState() {
    value = widget.value;
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    heightAnimate = Tween<double>(begin: 0.5, end: 1)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    paddingAnimate = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    int length = value.carts.length;
    int j = 0;
    int i = value.carts.isEmpty ? value.ongoingOrders.length : 0;
    value.cardKey = GlobalKey();
    print("new global key");
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value.showCarts && length + value.ongoingOrders.length > 1)
            ElevatedButton(
                onPressed: () {
                  if (!value.showCarts) {
                    value.toggleShowCarts(!value.showCarts);
                    // setState(() {});
                    controller.forward();
                  } else {
                    controller.reverse().then((_) {
                      value.toggleShowCarts(!value.showCarts);
                      // setState(() {});
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(4),
                    shape: const CircleBorder()),
                child: const Icon(Icons.close)),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              if (value.carts.isNotEmpty)
                for (i = 0; i < value.carts.length; i++)
                  value.restaurants!.restaurants!.where((res) {
                    return res.id == value.carts.keys.toList()[i];
                  }).isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          margin: EdgeInsets.only(
                              left: 2 * (length - i - 1) * paddingAnimate.value,
                              right:
                                  2 * (length - i - 1) * paddingAnimate.value,
                              top: 6 * (length - i - 1) * paddingAnimate.value +
                                  (value.showCarts ? 0 : 20)),
                          height: value.height == null
                              ? null
                              : value.height! *
                                  (length - i) *
                                  heightAnimate.value,
                          alignment: Alignment.bottomCenter,
                          child: CartTab(
                              key: i == 0 ? value.cardKey : null,
                              restaurant: value.restaurants!.restaurants!
                                  .firstWhere((res) {
                                return res.id == value.carts.keys.toList()[i];
                              }),
                              cartItems: calculateItems(
                                  value.carts[value.carts.keys.toList()[i]]!)),
                        ),
              for (j = 0; j < value.ongoingOrders.length; j++)
                Container(
                    margin: EdgeInsets.only(
                        left: 2 * (length + j) * paddingAnimate.value,
                        right: 2 * (length + j) * paddingAnimate.value,
                        top: 6 * (length + j) * paddingAnimate.value +
                            (value.showCarts ? 0 : 20)),
                    height: value.height == null
                        ? null
                        : value.height! *
                            (value.ongoingOrders.length + i - j) *
                            heightAnimate.value,
                    alignment: Alignment.bottomCenter,
                    child: OrderCard(
                      key: value.carts.isEmpty && j == 0 ? value.cardKey : null,
                      order: value.ongoingOrders[j],
                    )),
              if (!value.showCarts && length + value.ongoingOrders.length > 1)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        minimumSize: const Size.square(0)),
                    onPressed: () {
                      if (!value.showCarts) {
                        value.toggleShowCarts(!value.showCarts);
                        // setState(() {});
                        controller.forward();
                      } else {
                        controller.reverse().then((_) {
                          value.toggleShowCarts(!value.showCarts);
                          // setState(() {});
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "+${length + value.ongoingOrders.length - 1} more"),
                        const Icon(Icons.keyboard_arrow_up)
                      ],
                    )),
            ],
          ),
        ],
      ),
    );
  }
}

int calculateItems(List<CartModel> items) {
  int result = 0;
  items.forEach((item) {
    result += item.itemQuantity;
  });
  return result;
}

class CartTab extends StatelessWidget {
  const CartTab({super.key, required this.restaurant, required this.cartItems});
  final Restaurants restaurant;
  final int cartItems;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      elevation: 1,
      // shape: Border.all(color: Colors.grey),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(1.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.hardEdge,
                    child: restaurant.restaurantImages!.isEmpty
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
                            imageUrl: restaurant.restaurantImages![0],
                            placeholder: (context, url) => Image.asset(
                                  'assets/images/restaurantImage.png',
                                  fit: BoxFit.cover,
                                )),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.nukkadName!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context).push(transitionToNextScreen(
                              RestaurantScreen(
                                  restaurantID: restaurant.id!,
                                  isFavourite: false,
                                  restaurantName: restaurant.nukkadName!,
                                  res: restaurant)));
                        },
                        child: const Text(
                          "View Menu",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    UserModel? userModel = context.read<GlobalProvider>().user;
                    if (userModel != null &&
                        userModel.user!.addresses![0].hint == "temp") {
                      Toast.showToast(
                          message: "Please Enter details to proceed");
                      final user = await Navigator.of(context).push(
                          transitionToNextScreen(const RegistrationScreen()));
                      if (user is! UserModel) {
                        return;
                      } else {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('CurrentAddress',
                            user.user!.addresses![0].address!);
                        await prefs.setString(
                            'CurrentSaveAs', user.user!.addresses![0].saveAs!);
                        await prefs.setDouble('CurrentLatitude',
                            user.user!.addresses![0].latitude!);
                        await prefs.setDouble('CurrentLongitude',
                            user.user!.addresses![0].longitude!);
                        context.read<GlobalProvider>().user!.user = user.user;
                      }
                    }

                    if (!checkIfOpen(restaurant.operationalHours!,
                        restaurant.isOpen ?? false)) {
                      Toast.showToast(
                          message: "Restaurant is Closed at the moment",
                          isError: true);
                      return;
                    }
                    final temp = await Navigator.of(context).push(
                        transitionToNextScreen(CartScreen(
                            updateCartCounter: (bool value) {},
                            updateCartPrice: (double price) {},
                            restaurantname: restaurant.nukkadName!,
                            restaurantUID: restaurant.id!,
                            restaurant: restaurant)));
                    if (temp == true) {
                      Navigator.of(context).push(transitionToNextScreen(
                          RestaurantScreen(
                              restaurantID: restaurant.id!,
                              isFavourite: false,
                              restaurantName: restaurant.nukkadName!,
                              res: restaurant)));
                    }
                  },
                  style: const ButtonStyle().copyWith(
                      backgroundColor:
                          const WidgetStatePropertyAll(primaryColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        const TextSpan(
                            text: 'View Cart',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(
                            text:
                                "\n$cartItems ${cartItems > 1 ? "items" : 'item'}")
                      ]))),
              IconButton(
                  onPressed: () {
                    context
                        .read<GlobalProvider>()
                        .removeCart(restaurant.id!, context);
                  },
                  icon: const Icon(Icons.cancel_rounded))
            ],
          )
        ],
      ),
    );
  }

  bool checkIfOpen(OperationalHours timing, bool isopen) {
    bool isOpen = false;

    final openingHours = timing.toJson();

    var now = DateTime.now();
    var dayOfWeek = DateFormat('EEEE').format(now);

    // Fetch the opening and closing hours for the current day
    String? hours = openingHours[dayOfWeek];

    if (hours != null) {
      // Split hours into opening and closing time
      List<String> times = hours.split(' - ');
      String openingTime = times[0];
      String closingTime = times[1];

      // Parse opening and closing times with the current date
      DateTime open = DateFormat.jm().parse(openingTime);
      DateTime close = DateFormat.jm().parse(closingTime);

      // Adjust open and close to the current date
      open = DateTime(now.year, now.month, now.day, open.hour, open.minute);
      close = DateTime(now.year, now.month, now.day, close.hour, close.minute);

      // Handle overnight closing times
      if (close.isBefore(open)) {
        close = close.add(
            const Duration(days: 1)); // Add a day if it closes after midnight
      }

      var currentTime = DateTime.now();

      if (currentTime.isAfter(open) && currentTime.isBefore(close) && isopen) {
        isOpen = true;
      } else {
        isOpen = false;
      }
    } else {
      isOpen = false;
    }
    return isOpen;
  }
}
