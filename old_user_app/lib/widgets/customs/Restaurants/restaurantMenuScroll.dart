import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/category_model.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/network_image_widget.dart';

Widget restaurantMenuScroll(List<bool> isMenuSelected, Function(int) onTap,
    List<CategoryModel> categories, List<String> categoriesName) {
  return Container(
    padding: EdgeInsets.only(right: 1.w),
    width: 23.w,
    color: textWhite,
    child: categoriesName.isEmpty
        ? const Center(
            child: Text(
              AppStrings.noCategoriesFound,
            ),
          )
        : ListView.builder(
            itemCount: categoriesName.length,
            itemBuilder: (context, index) {
              return SizedBox(
                // height: 15.h,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onTap(index);
                      },
                      child: Container(
                        height: 7.h,
                        width: 23.w,
                        margin: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 1.h),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color:
                              isMenuSelected[index] ? primaryColor : textWhite,
                        ),
                        // child: Image.asset('assets/images/bowl_2.png'),

                        child: NetworkImageWidget(
                          imageUrl: categories[index].categoryImg!,
                          height: 7.h,
                          width: 23.w,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        categoriesName[index].replaceAll("_", " "),
                        style: isMenuSelected[index]
                            ? h6TextStyle.copyWith(color: primaryColor)
                            : body5TextStyle.copyWith(color: textGrey2),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
  );
}
