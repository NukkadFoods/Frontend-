import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/favorite_controller.dart';
import 'package:user_app/Controller/food/hidden_controller.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/strings.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Food/ratingWidget.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

Widget allRestaurants({
  required BuildContext context,
  /* String restaurantName*/ required List<Restaurants> restaurantsList,
  required List<Restaurants> favouriteList,
  required num userLat,
  required num userLng,
  NavigatorState? navigator,
}) {
  // Sort the restaurants by rating in descending order
  restaurantsList
      .sort((a, b) => b.getAverageRating().compareTo(a.getAverageRating()));

  return SizedBox(
    height: 75.h,
    child: ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return restaurant(
          context: context,
          restaurantModel: restaurantsList[index],
          isFavourite: favouriteList.contains(restaurantsList[index]),
          userLat: userLat,
          userLng: userLng,
          navigator: navigator,
        );
      },
    ),
  );
}

Widget restaurant({
  required BuildContext context,
  required Restaurants restaurantModel,
  String? restaurantName = "",
  required bool isFavourite,
  required num userLat,
  required num userLng,
  bool isHidden = false,
  NavigatorState? navigator,
}) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  final distance = calculateDistance(
    userLat,
    userLng,
    restaurantModel.latitude ?? 0,
    restaurantModel.longitude ?? 0,
  );
  final travelTime = estimateTravelTime(distance,
      timeToAddInMins: (restaurantModel.timetoprepare ?? 0).toInt());
  void favouriteHandler() async {
    if (isFavourite) {
      var result = await FavoriteController.removeFavorite(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          favorite: restaurantModel.id!);
      result.fold((String error) {}, (String success) {
        Fluttertoast.showToast(msg: ' $success', textColor: colorSuccess);
      });
    } else {
      var result = await FavoriteController.addFavorite(
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          favorite: restaurantModel.id!);
      result.fold((String error) {
        Fluttertoast.showToast(
            msg: 'Something went wrong ...!', textColor: primaryColor);
      }, (String success) {
        isFavourite = !isFavourite;

        Fluttertoast.showToast(
            msg: success, backgroundColor: textWhite, textColor: colorSuccess);
      });
    }
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          transitionToNextScreen(RestaurantScreen(
            res: restaurantModel,
            restaurantID: restaurantModel.id ?? "",
            isFavourite: isFavourite,
            restaurantName: restaurantModel.nukkadName ?? "",
          )));
    },
    child: Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 12.h,
          width: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.2.h, color: textGrey3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      height: 12.h,
                      width: 26.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DecoratedBox(
                        position: DecorationPosition.foreground,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            color: Colors.grey.withOpacity(
                                restaurantModel.isOpen! ? 0 : 0.8)),
                        child: NetworkImageWidget(
                          imageUrl: restaurantModel.restaurantImages!.isEmpty
                              ? ""
                              : restaurantModel.restaurantImages![0],
                        ),
                      )
                      // child: Image.asset(
                      //   'assets/images/restaurantImage.png',
                      //   fit: BoxFit.fill,
                      // ),
                      ),
                  Positioned(
                    bottom: 1.h,
                    left: 1.5.w,
                    right: 1.5.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            favouriteHandler();
                          },
                          child: isFavourite
                              ? const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border_rounded,
                                  color: textWhite,
                                ),
                        ),

                        // SvgPicture.asset(
                        //   'assets/icons/unlike_heart_icon.svg',
                        //   height: 3.h,
                        // ),
                        ratingWidget(
                          restaurantModel.getAverageRating(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 2.w,
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(
                            "${restaurantModel.nukkadName!}${restaurantModel.isOpen! ? "" : " (Closed)"}",
                            style: h5TextStyle.copyWith(
                                fontSize: 13.sp,
                                color: isdarkmode ? textGrey2 : textBlack),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      _buildMoreWidget(
                        context: context,
                        restaurantModel: restaurantModel,
                        isHidden: isHidden,
                        onHideSuccess: () {},
                        navigator: navigator,
                      ),
                    ],
                  )),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        restaurantModel.nukkadAddress ?? "",
                        style: body5TextStyle.copyWith(color: textGrey2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/timer_icon.svg',
                              height: 3.h,
                              color: primaryColor,
                            ),
                            SizedBox(width: 1.5.w),
                            Expanded(
                              child: Text(
                                travelTime,
                                style: body6TextStyle.copyWith(
                                  color: isdarkmode ? textGrey2 : textGrey1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/dot.svg',
                            height: 2.h,
                            color: isdarkmode ? textWhite : textGrey1,
                          ),
                          Expanded(
                            child: Text(
                              distance,
                              style: body6TextStyle.copyWith(
                                color: isdarkmode ? textWhite : textGrey1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ))
                    ],
                  ))
                ],
              )),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildMoreWidget({
  required BuildContext context,
  required Restaurants restaurantModel,
  required bool isHidden,
  required VoidCallback onHideSuccess,
  NavigatorState? navigator,
}) {
  return PopupMenuButton(
    color: const Color(0xFFB8B8B8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    onSelected: (value) async {
      if (value == 'hide') {
        final result = await HideController.addToHide(
          context: context,
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          restaurants: restaurantModel,
        );
        result.fold(
          (error) {
            if (navigator?.canPop() == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            }
          },
          (message) {
            if (navigator?.canPop() == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              onHideSuccess(); // Trigger UI refresh
            }
          },
        );
      } else if (value == 'remove' && isHidden) {
        final result = await HideController.removeFromHidden(
          context: context,
          uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
          restaurantsID: restaurantModel.id ?? "",
        );
        result.fold(
          (error) {
            if (navigator?.canPop() == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            }
          },
          (message) {
            if (navigator?.canPop() == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              onHideSuccess(); // Trigger UI refresh
            }
          },
        );
      } else if (value == 'share') {
        final url = "Check out this restaurant: ${restaurantModel.nukkadName}";
        // Share.share(url);
      }
    },
    itemBuilder: (context) => [
      if (!isHidden)
        PopupMenuItem(
          value: 'hide',
          child: SizedBox(
            width: 40.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  color: textBlack,
                  size: 15.sp,
                ),
                SizedBox(width: 1.5.w),
                Text('Hide Restaurant', style: body4TextStyle),
              ],
            ),
          ),
        ),
      if (isHidden)
        PopupMenuItem(
          value: 'remove',
          child: SizedBox(
            width: 40.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  color: textBlack,
                  size: 15.sp,
                ),
                SizedBox(width: 1.5.w),
                Text(
                  'Remove from Hidden',
                  style: body4TextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      PopupMenuItem(
        value: 'share',
        child: SizedBox(
          width: 42.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.share_outlined,
                color: textBlack,
                size: 15.sp,
              ),
              SizedBox(width: 1.5.w),
              Text('Share Restaurant', style: body4TextStyle),
            ],
          ),
        ),
      ),
    ],
  );
}
