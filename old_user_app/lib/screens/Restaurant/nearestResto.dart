import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Food/ratingWidget.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';

class Nearestresto extends StatelessWidget {
  final List<Restaurants> restaurants;
  final List<Restaurants>? favoriteRestaurants;
  final num userLat;
  final num userLng;

  const Nearestresto({
    required this.restaurants,
    required this.favoriteRestaurants,
    required this.userLat,
    required this.userLng,
    super.key,
  });



  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Restaurants'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png')
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: restaurants.isNotEmpty
              ? ListView.builder(
                  itemCount: restaurants.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final distance = calculateDistance(
                      userLat,
                      userLng,
                      restaurants[index].latitude ?? 0,
                      restaurants[index].longitude ?? 0,
                    );
                    final travelTime = estimateTravelTime(distance);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RestaurantScreen(
                                  res: restaurants[index],
                                      restaurantID: restaurants[index].id ?? "",
                                      isFavourite: favoriteRestaurants!
                                          .contains(restaurants[index]),
                                      restaurantName:
                                          restaurants[index].nukkadName ?? "",
                                    )));
                      },
                      child: Container(
                        height: 14.h,
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color:isdarkmode ? textBlack: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 0.2.h, color: textGrey3),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 23.h,
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
                                    height: 23.h,
                                    width: 35.w,
                                  ),
                                  Positioned(
                                    bottom: 1.5.h,
                                    left: 1.w,
                                    right: 1.w,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        favoriteRestaurants!.contains(
                                                restaurants[index])
                                            ? const Icon(
                                                Icons.favorite_rounded,
                                                color: Colors.red,
                                              )
                                            : const Icon(
                                                Icons.favorite_border_rounded,
                                                color: Colors.white,
                                              ),
                                        ratingWidget(restaurants[index]
                                            .getAverageRating()),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 1.h),
                                    child: Text(
                                      restaurants[index].nukkadName ?? "",
                                      style: h5TextStyle.copyWith(color: isdarkmode? textGrey2: textBlack),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/timer_icon.svg',
                                        color: primaryColor,
                                        height: 2.h,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        travelTime,
                                        style: body6TextStyle.copyWith(
                                            color:isdarkmode ? textGrey2: textBlack,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/dot.svg',
                                        height: 2.h,
                                        color: textGrey1,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        distance,
                                        style: body6TextStyle.copyWith(
                                            color: isdarkmode ? textGrey2: textBlack,
                                            fontWeight: FontWeight.w200,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(AppStrings.noRestaurantsFound,style: TextStyle(color: isdarkmode ? textWhite : textBlack),),
                ),
        ),
      ),
    );
  }
}
