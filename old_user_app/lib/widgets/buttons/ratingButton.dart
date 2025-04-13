import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

Widget ratingButton({
  required Function(double rating) onRatingSelected, // Callback function
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
    child: RatingBar.builder(
      initialRating: 0.0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      glow: false,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.w),
      itemSize: 4.h,
      updateOnDrag: true,
      itemBuilder: (context, _) => SvgPicture.asset(
        'assets/icons/star_icon.svg',
        color: const Color(0xffFFC000),
      ),
      onRatingUpdate: (rating) {
        onRatingSelected(rating); // Call the callback with the selected rating
      },
    ),
  );
}
