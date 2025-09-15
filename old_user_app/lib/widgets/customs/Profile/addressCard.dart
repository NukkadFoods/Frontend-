import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

Widget addressCard(assetName, String mainText, String address,
    BuildContext context, int index, UserModel? user,
    {Function(String address, String saveAs)? onDelete,
    bool showDelete = true}) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  void removeAddress(int index) async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";

    // Get the existing addresses
    List<Map<String, dynamic>> existingAddresses = user!.user!.addresses!
        .map((address) => {
              'address': address.address,
              'latitude': address.latitude,
              'longitude': address.longitude,
              'area': address.area,
              'hint': address.hint,
              'saveAs': address.saveAs,
            })
        .toList();

    // Check if the index is within the range
    if (index >= 0 && index < existingAddresses.length) {
      // Remove the address at the specified index
      final removedAddress = existingAddresses.removeAt(index);
      // user.user!.addresses!.removeAt(index);
      Toast.showToast(message: 'Address deleted successfully');
      // Navigator.of(context).pop();
      if (onDelete != null) {
        onDelete(removedAddress['address'], removedAddress['saveAs']);
      }
    } else {
      print('Invalid index'); // Handle invalid index
      return;
    }

    // Prepare the update data with the remaining addresses
    Map<String, dynamic> updateData = {
      'addresses': existingAddresses,
    };

    // Call the update method to save changes
    await UserController.updateUserById(
      id: userId,
      updateData: updateData,
      context: context,
    );
  }

  return Padding(
    padding: EdgeInsets.all(4.w),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.only(right: 2.w),
        //   child: SvgPicture.asset(
        //     assetName,
        //     color:isdarkmode ? textGrey2 : textBlack,
        //     height: 3.h,
        //     width: 3.h,
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            mainText.toLowerCase().trim() == 'home'
                ? Icons.home_outlined
                : Icons.home_work_outlined,
            size: 30,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize
                .min, // This allows the column to take minimum space
            children: [
              Text(mainText,
                  style: h5TextStyle.copyWith(
                      color: isdarkmode ? textGrey2 : textBlack)),
              SizedBox(height: 0.5.h),
              Text(
                address,
                style: body5TextStyle.copyWith(
                    color: isdarkmode ? textGrey2 : textBlack),
                maxLines: null, // Allows unlimited lines
                overflow: TextOverflow.visible, // No text cutoff
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 0.4.h),
              Row(
                children: [
                  // TextButton(
                  //   onPressed: () {
                  //  //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const LocationSetupScreen(isAdd: true,)));
                  //   },
                  //   child: Text(
                  //     'Edit',
                  //     style: h6TextStyle.copyWith(color: primaryColor),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  if (showDelete)
                    InkWell(
                      onTap: () {
                        removeAddress(index);
                      },
                      child: Text(
                        'Delete',
                        style: h6TextStyle.copyWith(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
