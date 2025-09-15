// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Controller/food/model/menu_model.dart';
import 'package:user_app/Controller/order/order_cost_calc.dart';
import 'package:user_app/Controller/subscription_resquest.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/buttons/textIconButton.dart';
import 'package:user_app/Controller/walletcontroller.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Cart/addressWidget.dart';
import 'package:user_app/Widgets/customs/Cart/walletCashWidget.dart';
import 'package:user_app/Widgets/customs/Orders/orderTypeSelector.dart';
import 'package:user_app/Widgets/customs/noteWidget.dart';
import 'package:user_app/Widgets/input_fields/textInputField.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/nointernet.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/Cart/cartbill.dart';
import 'package:user_app/widgets/customs/Cart/couponapply.dart';
import 'package:user_app/widgets/customs/Cart/orderStateSelector.dart';
import 'package:user_app/widgets/customs/Cart/thanksWidget.dart';
import 'package:user_app/widgets/customs/Cart/totalWidget.dart';
import 'package:user_app/widgets/customs/Orders/orderElement.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
    required this.updateCartCounter,
    required this.updateCartPrice,
    required this.restaurantname,
    required this.restaurantUID,
    required this.restaurant,
    this.menuItems,
  });
  final Function updateCartCounter;
  final Function updateCartPrice;
  final String restaurantname;
  final String restaurantUID;
  final Restaurants restaurant;
  final List<MenuItemModel>? menuItems;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double orderValue = 0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isDelivery = true;
  bool useWalletMoney = false;
  String cookingRequest = 'No request';
  String? deliveryInstructions;
  bool isLoaded = false;
  List<CartModel> cartModelList = [];
  double totalPrice = 0.0;
  UserModel? user;
  var Savedas;
  var area;
  String? couponcode;
  String? address = '';
  double actualcost = 0.0;
  var tip = 0;
  Map effectiveOrderCost = {};
  Map? orderCost;
  double discount = 0;
  bool walletcashused = false;
  double walletCashDebited = 0;
  double distance = 0;

  void _handleOrderTypeChanged(bool isDelivery) {
    if (isDelivery) {
      effectiveOrderCost = {};
      effectiveOrderCost.addAll(orderCost!);
      totalPrice =
          effectiveOrderCost['total'] - walletCashDebited + tip - discount;
    } else {
      totalPrice = effectiveOrderCost['total'] -
          walletCashDebited +
          discount -
          effectiveOrderCost['delivery_fee'] -
          effectiveOrderCost['handling_charges'] -
          effectiveOrderCost['shortValueOrder'] -
          effectiveOrderCost['surge'] -
          effectiveOrderCost['longDistanceCharge'];
      effectiveOrderCost['delivery_fee'] = 0.0;
      effectiveOrderCost['handling_charges'] = 0.0;
      effectiveOrderCost['shortValueOrder'] = 0.0;
      effectiveOrderCost['surge'] = 0.0;
      effectiveOrderCost['longDistanceCharge'] = 0.0;
      effectiveOrderCost['total'] = totalPrice.toDouble();
    }
    setState(() {
      this.isDelivery = isDelivery;
    });
  }

  routeRestaurant() {
    Navigator.of(context).pop(true);
  }

  int getResPrep() {
    double resPrep = 0;
    for (int i = 0; i < cartModelList.length; i++) {
      resPrep += cartModelList[i].timetoprepare;
    }
    return resPrep.toInt();
  }

  String prepTime() {
    double resPrep = 0;
    for (int i = 0; i < cartModelList.length; i++) {
      resPrep += cartModelList[i].timetoprepare;
    }
    double deliveryTime = (distance / 30) * 60;
    DateTime date = DateTime.now();
    effectiveOrderCost['expectedPrep'] =
        date.add(Duration(minutes: resPrep.round() + 2)).toIso8601String();
    return DateTime.now()
        .add(Duration(minutes: (resPrep + 5 + deliveryTime).toInt()))
        .toIso8601String();
  }

  void getCartList() async {
    // setState(() {
    // isLoaded = false;
    cartModelList = [];
    // });

    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);

    // Handle user fetch result
    userResult.fold((String text) {
      setState(() {
        isLoaded = true;
      });
      Toast.showToast(message: text, isError: true);
    }, (UserModel userModel) async {
      user = userModel;
      // cartModelList = userModel.user!.cart ?? [];
      if (userModel.user!.cart != null) {
        for (var item in userModel.user!.cart!) {
          if (item.restaurantId == widget.restaurantUID) {
            cartModelList.add(item);
          }
        }
      }
      if (cartModelList.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      orderValue =
          userModel.user!.getCartTotalForRestaurant(widget.restaurantUID);
      distance = getDistanceInKm(
          widget.restaurant.latitude!,
          widget.restaurant.longitude!,
          SharedPrefsUtil().getDouble("CurrentLatitude")!,
          SharedPrefsUtil().getDouble('CurrentLongitude')!);
      // if(list.contains(DateTime.now().hour))
      final surge = context.read<GlobalProvider>().constants['surge']
          [DateTime.now().hour.toString()];
      if (orderValue >= 70) {
        orderCost = await OrderCostCalculator.getCost(OrderCostRequestModel(
            orderValue: orderValue,
            deliveryStatus: DeliveryAndPreparationStatus.ontime,
            preparationStatus: DeliveryAndPreparationStatus.ontime,
            distanceInKms: distance,
            isPremium: SubscribeController.subscription == null ? 'no' : 'yes',
            isSurge: surge != null ? 'yes' : 'no',
            surgeType: surge ?? "none"));
        if (orderCost == null) {
          Navigator.pushReplacement(
              context, transitionToNextScreen(const NoInternetScreen()));
          return;
        }
        if (orderCost != null) {
          if (context.read<GlobalProvider>().streak == 6 &&
              !context.read<GlobalProvider>().orderedToday) {
            orderCost!['foodieReward'] = context
                .read<GlobalProvider>()
                .constants['foodieReward']
                .toDouble();
          }
          orderCost!['surgeType'] = surge ?? "none";
          effectiveOrderCost.addAll(orderCost!);
        }
        if (orderCost!.containsKey("error")) {
          Navigator.of(context).pop();
          Toast.showToast(
              message: "Server Error, Report to Admin", isError: true);
        }
        print(effectiveOrderCost);
        totalPrice = effectiveOrderCost['total'];
        actualcost = totalPrice;
        print('Total Price Without Tip=$totalPrice');
        if (walletcashused) {
          walletCashDebited = WalletController.wallet!.amount! >
                  effectiveOrderCost['usable_wallet_cash'].clamp(0, totalPrice)
              ? effectiveOrderCost['usable_wallet_cash'].clamp(0, totalPrice)
              : WalletController.wallet!.amount!;
        }
        discount = 0;
        couponcode = null;
        totalPrice = totalPrice + tip - walletCashDebited;

        print(totalPrice);
        SharedPrefsUtil().setDouble(AppStrings.cartItemTotalKey, totalPrice);
        isLoaded = true;
        Savedas = user?.user?.addresses![0].saveAs;
        area = user?.user?.addresses![0].area;
        address = user?.user?.addresses![0].area;
        saveaddresss();
        if (mounted) {
          setState(() {});
        }
      } else {
        Toast.showToast(
            message:
                "Minimum cart Total should be greater than ₹ 70 to place order",
            isError: true);
        Navigator.of(context).pop();
      }
    });
  }

  void saveaddresss() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullAddress', address ?? '123 main ');
  }

  @override
  void initState() {
    super.initState();
    getCartList();
  }

  updateCartTotal() {
    getCartList();
    // totalPrice = user!.user!.getCartTotalForRestaurant(widget.restaurantUID);
    // // setState(() {
    //   totalPrice = totalPrice + tip;
    // // });

    print(totalPrice);
    SharedPrefsUtil().setDouble(AppStrings.cartItemTotalKey,
        user!.user!.getCartTotalForRestaurant(widget.restaurantUID));
    SharedPrefsUtil().setInt(AppStrings.cartItemCountKey,
        user!.user!.getCartTotalQuantityForRestaurant(widget.restaurantUID));
    SharedPrefsUtil().setString('restaurantname', widget.restaurantname);
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    String restaurantname = widget.restaurantname;
    bool isDataLoaded = isLoaded && user != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios,
              color: isdarkmode ? textGrey2 : textBlack),
        ),
        title: isLoaded
            ? Text(SharedPrefsUtil().getString(AppStrings.userNameKey) ?? "",
                style: h5TextStyle.copyWith(
                    color: isdarkmode ? textGrey2 : textBlack))
            : const Text(''),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(1.w),
        child: isDataLoaded
            ? Stack(children: [
                Opacity(
                  opacity: 0.5,
                  child: Image.asset('assets/images/background.png'),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                        ),
                        child: OrderTypeSelector(
                            onOrderTypeChanged: _handleOrderTypeChanged),
                      ),
                      if (isDelivery)
                        AddressWidget(
                            address: address!,
                            saveAs: Savedas!,
                            filterLocation: LatLng(
                                widget.restaurant.latitude!.toDouble(),
                                widget.restaurant.longitude!.toDouble()),
                            onAddressSelected: () {
                              if (mounted) {
                                setState(() {
                                  isLoaded = false;
                                });
                              }
                              getCartList();
                            },
                            prepTime: getResPrep())
                      else
                        const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, right: 4.w),
                        child: Container(
                          height: 28,
                          width: 85.w,
                          decoration: BoxDecoration(
                              color: textGrey1,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                Icons.phone,
                                color: textWhite,
                              ),
                              isLoaded
                                  ? Text(
                                      SharedPrefsUtil().getString(
                                              AppStrings.userNameKey) ??
                                          "",
                                      style: TextStyle(
                                          color: textWhite, fontSize: 10.sp))
                                  : const Text(''),
                              const SizedBox(
                                width: 60,
                              ),
                              const VerticalDivider(
                                indent: 5,
                                endIndent: 5,
                              ),
                              Text(
                                user?.user?.contact ?? '',
                                style: TextStyle(
                                    color: textWhite, fontSize: 10.sp),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Padding(
                      //   padding:
                      //       EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                      //   child: SavingsWidget(isdarkmode),
                      // ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 3.w, right: 3.w, top: 1.h, bottom: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: textGrey2,
                            width: 0.2.h,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            !isLoaded
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : cartModelList.isEmpty
                                    ? const Center(
                                        child: Text("Cart is empty"),
                                      )
                                    : ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: cartModelList.length,
                                        itemBuilder: (context, index) {
                                          return OrderElement(
                                            cartModel: cartModelList[index],
                                            updateCartCounter:
                                                widget.updateCartCounter,
                                            updateCartPrice:
                                                widget.updateCartPrice,
                                            updateCartTotal: updateCartTotal,
                                            showDivider: !(index ==
                                                cartModelList.length - 1),
                                          );
                                        },
                                      ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.4.h),
                              child: textIconButton(
                                  'Add Items', routeRestaurant, isdarkmode),
                            ),
                            Divider(
                                color: textGrey1,
                                thickness: 0.5.w,
                                indent: 2.w,
                                endIndent: 2.w),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.4.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: textIconButton('Cooking Request',
                                        () async {
                                      final request =
                                          await getInstructionsDialog(
                                              cookingRequest,
                                              'Special cooking requests');
                                      if (request is String) {
                                        if (request.isEmpty) {
                                          cookingRequest = "No request";
                                        } else {
                                          cookingRequest = request;
                                        }
                                        setState(() {});
                                      }
                                    }, isdarkmode),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: VerticalDivider(
                                      color: textGrey1,
                                      thickness: 0.5.w,
                                    ),
                                  ),
                                  Flexible(
                                    child: textIconButton(
                                        'Delivery Instructions', () async {
                                      final request =
                                          await getInstructionsDialog(
                                              deliveryInstructions ?? '',
                                              'Delivery Instructions');
                                      if (request is String) {
                                        deliveryInstructions = request;
                                        setState(() {});
                                      }
                                    }, isdarkmode),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: CartBill(
                            context, effectiveOrderCost, discount, distance,
                            cartModelList: cartModelList,
                            walletCashUsed: walletcashused
                                ? WalletController.wallet!.amount! >
                                        effectiveOrderCost['usable_wallet_cash']
                                    ? effectiveOrderCost['usable_wallet_cash']
                                        .toDouble()
                                    : WalletController.wallet!.amount!
                                : null,
                            isDelivery: isDelivery),
                      ),
                      if (isDelivery)
                        Padding(
                          padding:
                              EdgeInsets.only(top: 1.h, left: 2.w, right: 3.w),
                          child: ThanksWidget(
                            onTipSelected: (selectedTip) {
                              setState(() {
                                tip = selectedTip;
                                totalPrice = (effectiveOrderCost.isEmpty
                                        ? 0.0
                                        : effectiveOrderCost["total"]) +
                                    tip -
                                    discount -
                                    walletCashDebited; // Add tip to the total
                              });
                              print('Tip selected: ₹$selectedTip');
                            },
                          ),
                        ),
                      WalletCash(
                        useWalletMoney,
                        effectiveOrderCost,
                        (newValue) {
                          setState(() {
                            useWalletMoney = newValue ?? false;
                            if (useWalletMoney && !walletcashused) {
                              walletCashDebited = WalletController
                                          .wallet!.amount! >
                                      effectiveOrderCost['usable_wallet_cash']
                                          .clamp(0, totalPrice)
                                          .toDouble()
                                  ? effectiveOrderCost['usable_wallet_cash']
                                      .clamp(0, totalPrice)
                                      .toDouble()
                                  : WalletController.wallet!.amount!;
                              totalPrice -= walletCashDebited;
                              walletcashused = true;
                            } else if (!useWalletMoney && walletcashused) {
                              // Reset the total price if unchecked and credit the amount back
                              walletCashDebited = 0;
                              totalPrice = effectiveOrderCost['total'] +
                                  tip -
                                  discount -
                                  walletCashDebited;
                              walletcashused = false;
                            }
                            effectiveOrderCost['walletCashUsed'] =
                                walletCashDebited;
                            orderCost!['walletCashUsed'] = walletCashDebited;
                          });
                        },
                        effectiveOrderCost['total'] + tip - discount,
                        isdarkmode,
                      ),
                      couponapply(context, (selectedCoupon, discountApplied) {
                        // Use the selectedCoupon and discountApplied values here
                        if (discount == 0 || selectedCoupon == null) {
                          setState(() {
                            discount =
                                discountApplied < orderCost!['nukkad_earning']
                                    ? discountApplied.toDouble()
                                    : orderCost!['nukkad_earning'].toDouble();
                            totalPrice = effectiveOrderCost['total'] +
                                tip -
                                walletCashDebited -
                                discount;
                            orderCost!['discount'] = discount;
                            effectiveOrderCost['discount'] = discount;
                            couponcode = selectedCoupon;
                          });
                          Toast.showToast(
                              message: selectedCoupon == null
                                  ? "Coupon removed!"
                                  : 'Coupon Applied! You Saved ${discount.toStringAsFixed(2)}');
                        } else {
                          Toast.showToast(message: 'Coupon already applied');
                        }
                      }, orderValue.ceilToDouble(), widget.restaurantUID,
                          couponcode, isdarkmode),
                      SizedBox(height: 1.h),
                      totalWidget(isdarkmode,
                          total: totalPrice.ceilToDouble(),
                          actualprice: actualcost),
                      SizedBox(height: 7.5.h),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0, // Floating at the bottom of the screen
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 50.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: textGrey1),
                        color: isdarkmode ? textBlack : textWhite),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.8.h,
                          horizontal: 1.h), // Adjust the padding as needed
                      child: OrderStateSelector(
                        prepTime: prepTime,
                        walletUsed: walletcashused,
                        walletAmount:
                            double.parse(walletCashDebited.toStringAsFixed(2)),
                        orderCost: effectiveOrderCost,
                        userData: user!,
                        context: context,
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                        restaurantname: restaurantname, // Default if null
                        totalprice:
                            totalPrice, // Pass the total price including the tip
                        restaurantuid:
                            widget.restaurantUID, // Default UID if null
                        drivertip: tip.toDouble(), // Safeguard if tip is null
                        cookingreq:
                            cookingRequest, // Default value for cooking request
                        code: couponcode ??
                            'no code', // Ensure coupon code is non-null
                        onDateSelected: (DateTime newDate) {
                          setState(() {
                            selectedDate = newDate;
                          });
                        },
                        onTimeSelected: (TimeOfDay newTime) {
                          setState(() {
                            selectedTime = newTime;
                          });
                        },
                        cartList: cartModelList,
                        discount: discount,
                        isDelivery: isDelivery, // Ensure cartList is not null
                        deliveryInstruction: deliveryInstructions,
                        hubId: widget.restaurant.hubId ?? "",
                      ),
                    ),
                  ),
                ),
              ])
            : const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
      ),
    );
  }

  Future getInstructionsDialog(String request, String heading) {
    return showDialog(
        context: context,
        builder: (context) {
          bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
          final cookingRequestController = TextEditingController(text: request);
          return Dialog(
            insetPadding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Text(
                    heading,
                    style: h4TextStyle.copyWith(color: primaryColor),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: textInputField('Add Requests',
                      cookingRequestController, (String input) {}, context,
                      capitalization: TextCapitalization.sentences),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  child: noteWidget(
                      'We will try our best to inculcate your requests. However, no refund request in this context will be possible.'),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isdarkmode ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: primaryColor, width: 1))),
                          child: Text(
                            "Cancel",
                            style: body3TextStyle.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600),
                          )),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(cookingRequestController.text);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: Text(
                            "  Save  ",
                            style: body3TextStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
