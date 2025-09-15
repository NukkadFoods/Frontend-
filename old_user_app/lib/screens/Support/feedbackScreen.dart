import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/order/orders_model.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/buttons/ratingButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, required this.restaurantname, required this.order});
  final String restaurantname;
  final Orders order;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  List<bool> isSelected = [false, false, false, false, false];
  List<String> overallParams = [
    'Taste',
    'Quality',
    'Quantity',
    'Price',
    'Delivery'
  ];

  List<bool> isTogglesVisible = [false, false, false];

  Widget rating() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
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
          print(rating);
        },
      ),
    );
  }

  void toggleSelection(int index) {
    setState(() {
      isSelected[index] = !isSelected[index];
    });
  }

  void toggleTogglesVisibility(int index) {
    setState(() {
      isTogglesVisible[index] = !isTogglesVisible[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: isdarkmode ? textGrey2 : textBlack),
        ),
        title: Text('Feedback and Reviews', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => toggleTogglesVisibility(0),
              child: Container(
                height: 20.h,
                width: 100.w,
                margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  border: Border.all(color: textGrey2, width: 0.2.h),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Overall Experience', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
                    Text('From ${widget.restaurantname}', style: body4TextStyle.copyWith(color: textGrey2)),
                    SizedBox(height: 1.h),
                    ratingButton(onRatingSelected: (double rating) {}),
                  ],
                ),
              ),
            ),
            if (isTogglesVisible[0])
              toggles(overallParams, isSelected, toggleSelection,isdarkmode),
            GestureDetector(
              onTap: () => toggleTogglesVisibility(1),
              child: Container(
                height: 35.h,
                width: 100.w,
                margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  border: Border.all(color: textGrey2, width: 0.2.h),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rate Dishes', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
                        SizedBox(width: 2.w),
                        SvgPicture.asset(
                          'assets/icons/dishes_icon.svg',
                          height: 4.h,
                          color: isdarkmode ? textGrey2 : textBlack,
                        ),
                      ],
                    ),
                    Text('From ${widget.restaurantname}', style: body4TextStyle.copyWith(color: textGrey2)),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.order.items?.length ?? 0,
                            itemBuilder: (context, index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.order.items![index].itemName}',
                                  style: titleTextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack),
                                ),
                                rating(),
                              ],
                            ),
                          ),
                          Divider(color: textGrey2, thickness: 0.2.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isTogglesVisible[1])
              toggles(overallParams, isSelected, toggleSelection,isdarkmode),
            GestureDetector(
              onTap: () => toggleTogglesVisibility(2),
              child: Container(
                height: 35.h,
                width: 100.w,
                margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  border: Border.all(color: textGrey2, width: 0.2.h),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Rate Delivery', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
                        SizedBox(width: 2.w),
                        SvgPicture.asset(
                          'assets/icons/delivering_icon.svg',
                          height: 4.h,
                          color: isdarkmode ? textGrey2 : textBlack,
                        ),
                      ],
                    ),
                    Text('From ${widget.restaurantname}', style: body4TextStyle.copyWith(color: textGrey2)),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery time', style: titleTextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
                          rating(),
                          Divider(color: textGrey2, thickness: 0.2.h),
                          Text('Delivery Partner behavior', style: titleTextStyle.copyWith(color: isdarkmode ? textGrey2 : textBlack)),
                          rating(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: mainButton(
                'Submit Feedback',
                textWhite,
                () {
                  Fluttertoast.showToast(
                    msg: 'Thank you for your response ..!!',
                    backgroundColor: textWhite,
                    textColor: colorSuccess,
                  );
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
Widget toggles(
    List<String> namesList, List<bool> isSelected, Function(int) onTap , bool isdarkmode) {
  return Container(
    height: 17.h,
    width: 100.w,
    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    decoration: BoxDecoration(
      color: isdarkmode ? textGrey1 : Color(0xFFe7ffe5) ,
      border: Border(
        top: BorderSide(
          color: textGrey2,
          width: 0.2.h,
        ),
        bottom: BorderSide(
          color: textGrey2,
          width: 0.2.h,
        ),
      ),
    ),
    child: Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'WHAT IMPRESSED YOU?'.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.sp,
              fontWeight: FontWeight.normal,
              color: isdarkmode ? textWhite : textBlack
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          height: 7.h,
          margin: EdgeInsets.symmetric(vertical: 2.h),
          child: ListView.builder(
            itemCount: namesList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  onTap(index);
                },
                child: Container(
                  width: 30.w,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected[index] ? primaryColor : isdarkmode ? textGrey1: Colors.white,
                    border: Border.all(
                      color: primaryColor,
                      width: 0.2.h,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      namesList[index],
                      style: h5TextStyle.copyWith(
                          color: isSelected[index] ? textWhite : textBlack),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}