import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../constants/colors.dart';
import '../../constants/texts.dart';

class TimeLineFilter extends StatefulWidget {
  final Function(String) onFilterSelected;

  const TimeLineFilter({super.key, required this.onFilterSelected});

  @override
  State<TimeLineFilter> createState() => _TimeLineFilterState();
}

class _TimeLineFilterState extends State<TimeLineFilter> {
  List<String> filterType = [
    'Today',
    'This Week',
    'This Month'
  ]; // Define filterType as List<String>
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4.5.h,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: filterType.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            key: Key(filterType[index]),
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Material(
              elevation: 3.0,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 29.w,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 0.2.h),
                  borderRadius: BorderRadius.circular(10),
                  color: selectedIndex == index ? primaryColor : textWhite,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onFilterSelected(filterType[index]);
                  },
                  child: Center(
                    child: Text(
                      filterType[index],
                      style: h6TextStyle.copyWith(
                        color:
                            selectedIndex == index ? textWhite : primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
