import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/cart_controller.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Controller/food/model/menu_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/utils/extensions.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class FoodItemWidget extends StatefulWidget {
  final MenuItemModel menuItem;
  final String restaurantId;
  final ValueChanged<bool> updateCartCounter;
  final ValueChanged<double> updateCartPrice;
  final bool isOpen;
  final List<CartModel>? cart;
  const FoodItemWidget({
    super.key,
    required this.menuItem,
    required this.restaurantId,
    required this.updateCartCounter,
    required this.updateCartPrice,
    required this.isOpen,
    this.cart,
  });

  @override
  _FoodItemWidgetState createState() => _FoodItemWidgetState();
}

class _FoodItemWidgetState extends State<FoodItemWidget> {
  int _counter = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!(widget.cart != null &&
        widget.cart!
            .where((item) => item.itemName == widget.menuItem.menuItemName)
            .isEmpty)) {
      _counter = widget.cart!
          .firstWhere((item) => item.itemName == widget.menuItem.menuItemName)
          .itemQuantity;
    }
  }

  void _incrementCounter() async {
    if (_isLoading) return; // Prevent multiple requests
    setState(() {
      _isLoading = true;
    });
    try {
      var result = await CartController.addToCart(
        context: context,
        uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
        cart: CartModel(
            // itemId: AppStrings.generateUniqueId(),
            itemId: widget.restaurantId.substring(0, 7) +
                widget.menuItem.menuItemName!,
            itemName: widget.menuItem.menuItemName ?? "",
            unitCost:
                double.parse(widget.menuItem.menuItemCost!.toStringAsFixed(2)),
            itemQuantity: 1,
            restaurantId: widget.restaurantId,
            type: widget.menuItem.label ?? "",
            timetoprepare: widget.menuItem.timeToPrepare ?? 0),
      );
      result.fold(
        (String error) {
          //  context.showSnackBar(message: error);
        },
        (String success) {
          // Update cart item count in SharedPreferences
          int currentCount =
              SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0;
          CartController.updateCartItemCount(currentCount + 1);
          widget.updateCartCounter(true);
          widget.updateCartPrice(
              double.parse(widget.menuItem.menuItemCost!.toString()));
          setState(() {
            _counter++;
          });
          // context.showSnackBar(message: success);
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _decrementCounter() async {
    if (_isLoading) return; // Prevent multiple requests
    setState(() {
      _isLoading = true;
    });
    try {
      var result = await CartController.removeFromCart(
        context: context,
        uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
        cart: CartModel(
            // itemId: AppStrings.generateUniqueId(),
            itemId: widget.restaurantId.substring(0, 7) +
                widget.menuItem.menuItemName!,
            itemName: widget.menuItem.menuItemName ?? "",
            unitCost:
                double.parse(widget.menuItem.menuItemCost!.toStringAsFixed(2)),
            itemQuantity: 1,
            restaurantId: widget.restaurantId,
            type: widget.menuItem.label ?? "",
            timetoprepare: widget.menuItem.timeToPrepare ?? 0),
      );
      result.fold(
        (String error) {
          // context.showSnackBar(message: error);
          Toast.showToast(message: 'Somethingw ent wrong !', isError: true);
        },
        (String success) {
          // Update cart item count in SharedPreferences
          int currentCount =
              SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0;
          CartController.updateCartItemCount(currentCount - 1);
          widget.updateCartCounter(false);
          widget.updateCartPrice(
              double.parse((-widget.menuItem.menuItemCost!).toString()));
          setState(() {
            _counter--;
          });
          // context.showSnackBar(message: success);
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 13.h,
      margin: EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Container(
              height: 15.h,
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.2.h,
                  color: textGrey2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    AppStrings.lableIcons[AppStrings.lable
                        .indexOf(widget.menuItem.label ?? AppStrings.lable[0])],
                    height: 4.h,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.menuItem.menuItemName ?? "").capitalize(),
                          style: body4TextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: isdarkmode ? textGrey2 : textBlack),
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹ ${widget.menuItem.menuItemCost ?? 0.0}',
                          style: body5TextStyle.copyWith(
                              fontSize: 15.sp,
                              color: isdarkmode ? textGrey2 : textBlack),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Stack(children: [
                    SizedBox(
                      width: 28.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                15.0), // You can adjust the radius as needed
                            child: NetworkImageWidget(
                              height: 10.h,
                              width: 25.w,
                              imageUrl: widget.menuItem.menuItemImageURL,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 3.h,
                          width: 20.w,
                          padding: EdgeInsets.symmetric(vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: isdarkmode ? textBlack : textWhite,
                            border: Border.all(
                              width: 0.2.h,
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: _counter > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: widget.isOpen
                                          ? _decrementCounter
                                          : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: const Color.fromARGB(
                                                82, 254, 107, 104)),
                                        child: Icon(Icons.remove,
                                            color: primaryColor, size: 12.sp),
                                      ),
                                    ),
                                    Text(
                                      '$_counter',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: primaryColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: widget.isOpen
                                          ? _incrementCounter
                                          : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(2)),
                                        child: Icon(Icons.add,
                                            color: isdarkmode
                                                ? textBlack
                                                : textWhite,
                                            size: 12.sp),
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap:
                                      widget.isOpen ? _incrementCounter : null,
                                  child: Text('Add',
                                      textAlign: TextAlign.center,
                                      style: body5TextStyle.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                        ),
                      ),
                    ),
                  ])
                ],
              ),
            ),
            Visibility(
              visible: _isLoading,
              child: Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
