import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/promotions/Coupon_controller.dart';
import 'package:restaurant_app/Controller/promotions/Coupon_model.dart';
import 'package:restaurant_app/Widgets/buttons/mainButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/customs/loading_popup.dart';
import 'package:restaurant_app/Widgets/input_fields/numberInputField.dart';
import 'package:restaurant_app/Widgets/toast.dart';
import 'package:sizer/sizer.dart';

class CouponsList extends StatefulWidget {
  final List<Coupon> coupons;
  final VoidCallback onRefresh; // Add a callback parameter

  const CouponsList(
      {super.key, required this.coupons, required this.onRefresh});

  @override
  State<CouponsList> createState() => _CouponsListState();
}

@override
State<CouponsList> createState() => _CouponsListState();

class _CouponsListState extends State<CouponsList> {
  void deactivateCoupon(String couponCode, String status) {
    if (status == 'active') {
      CouponController.updateCouponStatus(couponCode, 'expired');
      Toast.showToast(message: 'Coupon deactivated Successfully ..!!');
      widget.onRefresh();
    } else {
      CouponController.updateCouponStatus(couponCode, 'active');
      Toast.showToast(message: 'Coupon activated Successfully ..!!');
      widget.onRefresh();
    }
    setState(() {});
// Call the refresh callback from the parent screen
    widget.onRefresh();
    if (kDebugMode) {
      print('Deactivated coupon code: $couponCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.h, // Adjust height as needed
      child: widget.coupons.isNotEmpty
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.coupons.length,
              itemBuilder: (context, index) {
                final coupon = widget.coupons[index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0), // Add gap here
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.2.h, color: textGrey3),
                      color: Color(0xffF1FFF0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: textGrey2
                              .withAlpha((255 * 0.3).toInt()), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset:
                              Offset(2, 2), // Offset in the x and y directions
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.couponCode,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'On Orders Above ₹${coupon.minOrderValue}',
                          style: TextStyle(
                            color: Color(0Xff35BA2A),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => deactivateCoupon(
                                  coupon.couponCode, coupon.status),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: coupon.status == 'active'
                                      ? Colors.red
                                      : Colors.green,
                                  foregroundColor: textWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(
                                coupon.status == 'active'
                                    ? 'Deactivate'
                                    : "Activate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                    onPressed: () => showUpdateSheet(coupon),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined),
                                        Text('   Edit   ')
                                      ],
                                    )),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                    onPressed: () => showDeleteDialog(
                                        context, coupon.couponCode),
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 3),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline),
                                        Text('  Delete  ')
                                      ],
                                    ))
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No coupons available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }

  void showUpdateSheet(Coupon coupon) {
    final discountController =
        TextEditingController(text: coupon.discountPercentage.toString());
    final flatRsOffController =
        TextEditingController(text: coupon.flatRsOff.toString());
    final orderValueController =
        TextEditingController(text: coupon.minOrderValue.toString());
    final maxDiscountController =
        TextEditingController(text: coupon.maxDiscount.toString());
    showBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            side: BorderSide(color: Colors.blueGrey)),
        context: context,
        builder: (context) => Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: Text('Edit Coupon'),
                    centerTitle: true,
                    leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Transform.rotate(
                            angle: 3.147 / 4,
                            child: Icon(Icons.add, size: 30))),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: numberInputField('discount percentage'.toUpperCase(),
                        discountController, (String input) {}),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: numberInputField('flat rs off'.toUpperCase(),
                        flatRsOffController, (String input) {}),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: numberInputField('Min. order value'.toUpperCase(),
                        orderValueController, (String input) {}),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: numberInputField('Max. discount'.toUpperCase(),
                        maxDiscountController, (String input) {}),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 2.h,
                    ),
                    child: mainButton('Update', textWhite, () async {
                      if (discountController.text.isEmpty ||
                          flatRsOffController.text.isEmpty ||
                          orderValueController.text.isEmpty ||
                          maxDiscountController.text.isEmpty) {
                        Toast.showToast(
                            message: "Please Enter all fields.", isError: true);
                        return;
                      }
                      showLoadingPopup(context, "Updating Coupon...");
                      final result = await CouponController.updateCoupon(Coupon(
                          createdById: coupon.createdById,
                          couponCode: coupon.couponCode,
                          discountPercentage:
                              int.parse(discountController.text),
                          flatRsOff: int.parse(flatRsOffController.text),
                          minOrderValue: int.parse(orderValueController.text),
                          maxDiscount: int.parse(maxDiscountController.text),
                          status: coupon.status));
                      Navigator.of(context).pop();
                      if (result) {
                        widget.onRefresh();
                        Navigator.of(context).pop();
                        Toast.showToast(
                            message: "Updated Coupon Successfully",
                            isError: false);
                      } else {
                        Toast.showToast(
                            message: "Unable to update Coupon", isError: true);
                      }
                    }),
                  ),
                ],
              ),
            ));
  }

  void showDeleteDialog(BuildContext context, String CouponCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete this Coupon?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: textBlack),
              ),
            ),
            TextButton(
              onPressed: () {
                // Trigger the delete function
                CouponController.deleteCoupon(CouponCode);
                widget.onRefresh();
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete',
                style: TextStyle(color: textBlack),
              ),
            ),
          ],
        );
      },
    );
  }
}
