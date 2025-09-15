import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Food/ratingWidget.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

Widget restaurantSlider(BuildContext context,
    {required List<Restaurants> restaurants,
    required List<Restaurants>? favoriteRestaurants,
    required num userLat,
    required num userLng}) {
  bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return restaurants.isNotEmpty
      ? restaurants.isNotEmpty
          ? ListView.builder(
              itemCount: restaurants.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final distance = calculateDistance(
                  userLat,
                  userLng,
                  restaurants[index].latitude ?? 0,
                  restaurants[index].longitude ?? 0,
                );
                final travelTime = estimateTravelTime(distance,
                    timeToAddInMins:
                        (restaurants[index].timetoprepare ?? 0).toInt());
                return GestureDetector(
                  onTap: () async {
                    // Store restaurant latitude and longitude in shared preferences
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setDouble('restaurant_latitude',
                        restaurants[index].latitude?.toDouble() ?? 0);
                    await prefs.setDouble('restaurant_longitude',
                        restaurants[index].longitude?.toDouble() ?? 0);

                    Navigator.push(
                        context,
                        transitionToNextScreen(RestaurantScreen(
                          restaurantID: restaurants[index].id ?? "",
                          isFavourite:
                              favoriteRestaurants.contains(restaurants[index]),
                          res: restaurants[index],
                          restaurantName: restaurants[index].nukkadName ?? "",
                        )));
                  },
                  child: Container(
                    height: 14.h,
                    width: 35.w,
                    margin: EdgeInsets.only(right: 3.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.2.h, color: textGrey3),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          clipBehavior: Clip.hardEdge,
                          height: 14.h,
                          width: 35.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              NetworkImageWidget(
                                imageUrl: restaurants[index]
                                        .restaurantImages!
                                        .isEmpty
                                    ? ""
                                    : restaurants[index].restaurantImages![0],
                                height: 14.h,
                                width: 35.w,
                              ),
                              // SizedBox(
                              //   height: 16.h,
                              //   child: Image.asset(
                              //     'assets/images/restaurantImage.png',
                              //     fit: BoxFit.fill,
                              //   ),
                              // ),
                              Positioned(
                                bottom: 1.5.h,
                                left: 1.w,
                                right: 1.w,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    favoriteRestaurants!
                                            .contains(restaurants[index])
                                        ? const Icon(
                                            Icons.favorite_rounded,
                                            color: Colors.red,
                                          )
                                        : const Icon(
                                            Icons.favorite_border_rounded,
                                            color: Colors.white,
                                          ),
                                    // SvgPicture.asset(
                                    //   'assets/icons/unlike_heart_icon.svg',
                                    //   height: 3.h,
                                    //   color: Colors.white,
                                    // ),
                                    ratingWidget(
                                        restaurants[index].getAverageRating()),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          height: 0.03.h,
                          color: textGrey2,
                          indent: 1.w,
                          endIndent: 1.w,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Text(
                            restaurants[index].nukkadName ?? "",
                            style: isdarkmode
                                ? h6TextStyle.copyWith(color: textGrey2)
                                : h6TextStyle,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/timer_icon.svg',
                                    color: primaryColor,
                                    height: 3.h,
                                  ),
                                  Expanded(
                                    child: Text(
                                      travelTime,
                                      style: body6TextStyle.copyWith(
                                          color: isdarkmode
                                              ? textGrey2
                                              : textGrey1,
                                          fontWeight: FontWeight.w200),
                                      textAlign: TextAlign.start,
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
                                    color: textGrey1,
                                  ),
                                  Expanded(
                                    child: Text(
                                      distance,
                                      style: body6TextStyle.copyWith(
                                          color: isdarkmode
                                              ? textGrey2
                                              : textGrey1,
                                          fontWeight: FontWeight.w200),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                AppStrings.noRestaurantsFound,
                style: TextStyle(color: isdarkmode ? textWhite : textBlack),
              ),
            )
      : Center(
          child: Text(
            AppStrings.noRestaurantsFound,
            style: TextStyle(color: isdarkmode ? textWhite : textBlack),
            textAlign: TextAlign.center,
          ),
        );
}
