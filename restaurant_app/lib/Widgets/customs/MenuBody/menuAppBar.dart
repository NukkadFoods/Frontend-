import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/restaurant_model.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/nukkad_settting.dart';
import 'package:restaurant_app/Screens/Navbar/menuBody.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/pagetransition.dart';
import 'package:restaurant_app/Widgets/forms/dishesForm.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

class MenuAppBar extends StatelessWidget {
  const MenuAppBar({
    Key? key,
    required this.categories,
    required this.subCategories,
    required this.subCategoriesMap,
    required this.menuRefreshCallback,
    required this.fullMenu,
  }) : super(key: key);

  final List categories;
  final List<String> subCategories;
  final Map<String, List> subCategoriesMap;
  final MenuRefreshCallback menuRefreshCallback;
  final Map fullMenu;

  @override
  Widget build(BuildContext context) {
    final restaurantModel = RestaurantModel.fromJson(
        json.decode(SharedPrefsUtil().getString(AppStrings.restaurantModel)!));

    return Material(
      elevation: 5,
      child: Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: h3TextStyle,
                  ),
                  InkWell(
                    onTap: () {
                      // showModalBottomSheet(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return Container(
                      //       decoration: BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.vertical(
                      //             top: Radius.circular(5.0)),
                      //       ),
                      //       padding: EdgeInsets.all(16.0),
                      //       child: AddItems(
                      //           categories: widget.categories,
                      //           subCategories: widget.subCategories,
                      //           closeBottomSheet: () {
                      //             Navigator.pop(context);
                      //           },
                      //           subCategoriesMap: widget.subCategoriesMap,
                      //           menuRefreshCallback:
                      //               widget.menuRefreshCallback),
                      //     );
                      //   },
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.vertical(
                      //         top: Radius.circular(5.0)),
                      //   ),
                      //   isScrollControlled: true,
                      // );
                      Navigator.of(context).push(transitionToNextScreen(
                          DishesForm(
                              categories: categories,
                              subCategories: subCategories,
                              subCategoriesMap: subCategoriesMap,
                              menuRefreshCallback: menuRefreshCallback,
                              fullMenu: fullMenu)));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Add +',
                        style: h4TextStyle.copyWith(color: textWhite),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          transitionToNextScreen(NukkadSettingWidget()));
                    },
                    child: Container(
                      width: 25.w,
                      height: 25.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        border: Border.all(width: 0.5.h, color: primaryColor),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              restaurantModel.user!.restaurantImages!.isNotEmpty
                                  ? restaurantModel.user!.restaurantImages![0]
                                  : '',
                          placeholder: (context, url) =>
                              Image.asset('assets/images/get_started.png'),
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/get_started.png'),
                          width: 25.w,
                          height: 25.w,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurantModel.user!.nukkadName ?? '',
                          style: h4TextStyle.copyWith(color: primaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          restaurantModel.user!.nukkadAddress ?? '',
                          style: body4TextStyle.copyWith(fontSize: 13.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          restaurantModel.user!.city ?? '',
                          style: body5TextStyle.copyWith(color: textGrey3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
