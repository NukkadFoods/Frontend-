import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/cart_controller.dart';
import 'package:user_app/Controller/food/model/cart_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/utils/extensions.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class OrderElement extends StatefulWidget {
  const OrderElement({
    super.key,
    required this.cartModel,
    required this.updateCartCounter,
    required this.updateCartPrice,
    required this.updateCartTotal,
    this.showDivider = true,
  });
  final CartModel cartModel;
  final Function updateCartCounter;
  final Function updateCartPrice;
  final Function updateCartTotal;
  final bool showDivider;

  @override
  State<OrderElement> createState() => _OrderElementState();
}

class _OrderElementState extends State<OrderElement> {
  late int _counter;
  int indexType = 0;
  bool _isLoading = false;

  static const List<String> subCategory = [
    'Veg',
    'Non-Veg',
    'Vegan',
    'Gluten-Free',
    'Dairy Free',
  ];
  final List<String> subCategoryImage = [
    'assets/icons/veg_icon.png',
    'assets/icons/non_veg_icon.png',
    'assets/icons/vegan_icon.png',
    'assets/images/glutenfree.png',
    'assets/icons/gluten_free_icon.png'
  ];

  @override
  void initState() {
    super.initState();
    _counter = widget.cartModel.itemQuantity;
    // indexType = subCategory.indexOf(widget.cartModel.type);
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
        cart: widget.cartModel.copyWith(
          itemQuantity: 1,
          //  itemId: AppStrings.generateUniqueId(),
        ),
      );
      result.fold(
        (String error) {
          Toast.showToast(message: 'Something went wrong!', isError: true);
        },
        (String success) {
          int currentCount =
              SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0;
          CartController.updateCartItemCount(currentCount + 1);
          setState(() {
            _counter++;
          });
          widget.updateCartCounter(true);
          widget.updateCartPrice(
              double.parse(widget.cartModel.unitCost.toString()));
          widget.updateCartTotal();
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _decrementCounter() async {
    if (_isLoading || _counter <= 0) {
      return;
    } // Prevent multiple requests and decrementing below zero
    setState(() {
      _isLoading = true;
    });
    try {
      if (_counter >= 1) {
        // Update the cart item quantity
        var result = await CartController.removeFromCart(
            context: context,
            uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
            cart: widget.cartModel);
        result.fold(
          (String error) {
            // context.showSnackBar(message: error);
            Toast.showToast(message: 'Something went wrong!', isError: true);
          },
          (String success) {
            // Item removed successfully
            int currentCount =
                SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0;
            CartController.updateCartItemCount(currentCount - 1);
            setState(() {
              _counter--;
            });
            widget.updateCartCounter(false);
            widget.updateCartPrice(
                double.parse((-widget.cartModel.unitCost).toString()));
            widget.updateCartTotal();
          },
        );
      } else {
        // Remove the cart item
        var result = await CartController.removeFromCart(
            context: context,
            uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
            cart: widget.cartModel);
        result.fold(
          (String error) {
            // context.showSnackBar(message: error);
            Toast.showToast(message: 'Something went wrong!', isError: true);
          },
          (String success) {
            // Item removed successfully
            int currentCount =
                SharedPrefsUtil().getInt(AppStrings.cartItemCountKey) ?? 0;
            CartController.updateCartItemCount(currentCount - 1);
            _counter = 0;
            if (mounted) {
              setState(() {});
            }
            widget.updateCartCounter(false);
            widget.updateCartPrice(
                double.parse((-widget.cartModel.unitCost).toString()));
            widget.updateCartTotal();
          },
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        _counter > 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    horizontalTitleGap: 5,
                    minLeadingWidth: 0,
                    minVerticalPadding: 4,
                    minTileHeight: 0,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 13.0),
                      child: Image.asset(
                        subCategoryImage[indexType],
                        height: 2.7.h,
                      ),
                    ),
                    title: Text(
                      widget.cartModel.itemName.capitalize(),
                      style: body4TextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isdarkmode ? textGrey2 : textBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '₹ ${widget.cartModel.unitCost.toStringAsFixed(1)}',
                      style: body5TextStyle.copyWith(
                          fontWeight: FontWeight.w200,
                          color: isdarkmode ? textGrey2 : textBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 25.w),
                          child: Card(
                            elevation: 1,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _decrementCounter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: const Color.fromARGB(
                                              100, 231, 100, 100)),
                                      child: Icon(Icons.remove,
                                          color: primaryColor, size: 12.sp),
                                    ),
                                  ),
                                  Text(
                                    '$_counter',
                                    textAlign: TextAlign.center,
                                    style: body3TextStyle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                      color: primaryColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _incrementCounter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: primaryColor),
                                      child: Icon(Icons.add,
                                          color: isdarkmode
                                              ? textBlack
                                              : textWhite,
                                          size: 12.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '₹ ${(widget.cartModel.unitCost * _counter).toStringAsFixed(1)}',
                            style: body4TextStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isdarkmode ? textGrey2 : textBlack),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showDivider)
                    Divider(
                      thickness: 0.2.h,
                      color: textGrey2,
                      indent: 2.w,
                      endIndent: 2.w,
                    ),
                ],
              )
            : const Text('no item'),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
      ],
    );
  }
}
