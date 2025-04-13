import 'package:flutter/material.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:sizer/sizer.dart';

class RestaurantOperatingHoursWidget extends StatefulWidget {
  final List<bool> isOpen;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final List<String> daysOfWeek;
  final Function(List<bool>, TimeOfDay, TimeOfDay) onValuesChanged;
  final EdgeInsetsGeometry? padding;

  RestaurantOperatingHoursWidget(
      {required this.isOpen,
      required this.openingTime,
      required this.closingTime,
      required this.onValuesChanged,
      required this.daysOfWeek,
      this.padding});

  @override
  _RestaurantOperatingHoursWidgetState createState() =>
      _RestaurantOperatingHoursWidgetState();
}

class _RestaurantOperatingHoursWidgetState
    extends State<RestaurantOperatingHoursWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      margin: widget.padding ?? EdgeInsets.symmetric(horizontal: 3.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 0.2.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select restaurant opening days',
            style: body4TextStyle.copyWith(
                color: Color.fromARGB(255, 185, 184, 184)),
          ),
          //SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 6.0, // Adjust the space between rows
              crossAxisSpacing: 10.w,
              childAspectRatio: 2.5, // Adjust aspect ratio
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Card(
                surfaceTintColor: bgColor,
                color: bgColor,
                elevation: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.isOpen[index],
                      onChanged: (newValue) {
                        setState(() {
                          widget.isOpen[index] = newValue!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    Expanded(
                      child: Text(
                        _getDay(index),
                        style: TextStyle(fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          columnHours(),
        ],
      ),
    );
  }

  Widget columnHours() => Column(children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Select restaurant opening /closing time',
            style: body4TextStyle.copyWith(color: textGrey3),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Card(
            color: bgColor,
            surfaceTintColor: bgColor,
            child: Row(
              children: [
                _buildHoursWidget(
                    text: 'Opening',
                    textColor: colorSuccess,
                    image: 'assets/images/openRes.png',
                    time: widget.openingTime.format(context),
                    onTap: () => _selectTime(context, 'opening')),
                SizedBox(
                  width: 2.w,
                ),
                _buildHoursWidget(
                    text: 'Closing',
                    textColor: colorFailure,
                    image: 'assets/images/closeRes.png',
                    time: widget.closingTime.format(context),
                    onTap: () => _selectTime(context, 'closing')),
              ],
            ))
      ]);

  Widget _buildHoursWidget({
    required String text,
    required Color textColor,
    required String image,
    required String time,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: body5TextStyle.copyWith(
                    color: textColor,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 1.h,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor, width: 0.2.w),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: colordenger.withOpacity(0.5), // Shadow color
                    //     spreadRadius: 2, // Spread radius
                    //     blurRadius: 5, // Blur radius
                    //     offset:
                    //         Offset(0, 2), // Offset in the x and y directions
                    //   ),
                    // ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          image,
                          cacheWidth: 50,
                        ),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          time,
                          style: body5TextStyle.copyWith(
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      );

  String _getDay(int index) {
    if (index >= 0 && index <= 6) {
      return widget.daysOfWeek[index];
    } else {
      return '';
    }
  }

  Future<void> _selectTime(BuildContext context, String timeType) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          timeType == 'opening' ? widget.openingTime : widget.closingTime,
          builder:(context, child) => Theme(data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData().copyWith(
              dayPeriodColor: Colors.red
            )
          ), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (timeType == 'opening') {
          widget.onValuesChanged(widget.isOpen, picked, widget.closingTime);
        } else {
          widget.onValuesChanged(widget.isOpen, widget.openingTime, picked);
        }
      });
    }
  }
}
