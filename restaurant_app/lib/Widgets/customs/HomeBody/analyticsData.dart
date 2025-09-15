import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class AnalyticsData extends StatefulWidget {
  const AnalyticsData({super.key});

  @override
  State<AnalyticsData> createState() => _AnalyticsDataState();
}

class _AnalyticsDataState extends State<AnalyticsData> {
  List headings = [
    'Sales',
    'Avg. Value',
    'Orders',
    'Cancellations',
    'Avg. per Items',
    'Quantity'
  ];

  List values = ['₹550', '₹102', '5', '2', '₹89', '8'];

  List analysis = [
    '13% increase in sales from yesterday',
    '3% decrease in Average order value from yesterday',
    '31% decrease in Average orders from yesterday',
    '50% increase in Average order value from yesterday',
    '31% decrease in Average cost  per item from yesterday',
    '12% increase in Total no. of items from yesterday'
  ];

  List isGrowing = [true, false, false, true, false, true];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        children: List.generate(6, (index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.4.h),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 45.w,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: textWhite,
                  border: Border.all(color: textGrey2, width: 0.2.h),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Text(
                      headings[index],
                      style: h6TextStyle.copyWith(fontSize: 12.sp),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Divider(
                      color: textGrey2,
                      thickness: 0.2.h,
                      indent: 3.w,
                      endIndent: 3.w,
                    ),
                    const Spacer(),
                    Text(
                      values[index],
                      style: h4TextStyle.copyWith(color: primaryColor),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isGrowing[index]
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: isGrowing[index] ? colorSuccess : colorFailure,
                        ),
                        SizedBox(
                          width: 30.w,
                          child: Text(
                            analysis[index],
                            style: body6TextStyle.copyWith(
                              fontSize: 8.sp,
                              color: isGrowing[index]
                                  ? colorSuccess
                                  : colorFailure,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
