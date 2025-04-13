import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/Restaurant/restaurantScreen.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

Widget sectionSlider(
  String headerText,
  List<Restaurants> favouriteRestaurants,
  bool isFavouriteRestaurantsLoaded,
  BuildContext context
) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
  return 
  favouriteRestaurants.isEmpty ? const SizedBox.shrink() :
  SizedBox(
    height: 21.h,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
          child: Text(headerText.toUpperCase(), style: isdarkmode ?  titleTextStyle.copyWith(fontSize: 13.sp,color: textGrey2) : titleTextStyle.copyWith(fontSize: 13.sp)),
        ),
        SizedBox(
          height: 15.h,
          child: !isFavouriteRestaurantsLoaded
              ? const Center(child: CircularProgressIndicator())
              : favouriteRestaurants.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noRestaurantsFound),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favouriteRestaurants.length,
                      itemBuilder: (context, index) {
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: SizedBox(
                            height: 15.h,
                            width: 12.h,
                            child: GestureDetector(
                              onTap:(){ Navigator.push(
                        context,
                        transitionToNextScreen(RestaurantScreen(
                                  res : favouriteRestaurants[index],
                                  restaurantID: favouriteRestaurants[index].id ?? "",
                                  isFavourite: true,
                                  restaurantName:
                                     favouriteRestaurants[index].nukkadName ?? "",
                                )));},
                              child: Column(
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: NetworkImageWidget(
                                      height: 10.h,
                                      width: 10.h,
                                      imageUrl: favouriteRestaurants[index]
                                              .restaurantImages!
                                              .isNotEmpty
                                          ? favouriteRestaurants[index]
                                              .restaurantImages![0]
                                          : "",
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: 12.h,
                                  //   width: 12.h,
                                  //   child: Image.asset('assets/images/waffle.png'),
                                  // ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.center,
                                      child: Text(
                                        favouriteRestaurants[index].nukkadName ??
                                            "",
                                        style: isdarkmode ?h6TextStyle.copyWith(color: textGrey2) :  h6TextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
        ),
      ],
    ),
  );
}
