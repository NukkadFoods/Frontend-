import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

Widget profileHeader({required String name, required String? gender, String? imageUrl,bool? isdarkmode}) {
  return SizedBox(
    height: 35.h,
    child: Column(
      children: [
        Text('Profile', style: h3TextStyle.copyWith(color: isdarkmode! ? textWhite: textBlack)),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 18.h, // Adjust size accordingly
                width: 18.h,  // Keeping it the same to make the container a circle
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: 4), // Border with primary color
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100), // To ensure the image is clipped within a circle
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 16.h, // Adjust height inside the circle
                          width: 16.h,  // Adjust width inside the circle
                          fit: BoxFit.cover, // To make sure the image covers the container properly
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child; // Show the image when loaded
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(), // Show loading indicator
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return gender?.toLowerCase() == 'male'
                                ? Image.asset(
                                    'assets/images/boyprofile.png',
                                    height: 16.h,
                                    width: 16.h,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/profile.png',
                                    height: 16.h,
                                    width: 16.h,
                                    fit: BoxFit.cover,
                                  );
                          },
                        )
                      : (gender?.toLowerCase() == 'male'
                          ? Image.asset(
                              'assets/images/boyprofile.png',
                              height: 16.h,
                              width: 16.h,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/profile.png',
                              height: 16.h,
                              width: 16.h,
                              fit: BoxFit.cover,
                            )),
                ),
              ),
              SizedBox(height: 1.h),
              Text(name.toUpperCase(),
                  style: h5TextStyle.copyWith(color:isdarkmode! ? textWhite: textBlack)),
            ],
          ),
        ),
      ],
    ),
  );
}
