import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/texts.dart';

class SortingBar extends StatefulWidget {
  final Function(String) onOrderFilterChanged;
  final bool type;
  const SortingBar(
      {super.key, required this.type, required this.onOrderFilterChanged});

  @override
  State<SortingBar> createState() => _SortingBarState();
}

class _SortingBarState extends State<SortingBar> {
  List<String> sortFilter = [
    'Newest First',
    'Oldest First',
    'Order Cost : Low to High',
    'Order Cost : High to Low',
  ];
  String? selectedSortOption;

  Widget selectorButton(
      Color color, Color borderColor, String buttonText, Color textColor) {
    return SizedBox(
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            border: Border.all(color: borderColor, width: 0.2.h),
          ),
          child: Text(
            buttonText,
            style: h6TextStyle.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  void _showSortingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the bottom sheet to be scrollable
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: textWhite,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sort',
                        style: h3TextStyle,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          size: 25.sp,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: textGrey2,
                  thickness: 0.2.h,
                  indent: 2.w,
                  endIndent: 2.w,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortFilter.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSortOption = sortFilter[index];
                          });
                          // print(selectedSortOption);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                sortFilter[index],
                                style: body3TextStyle.copyWith(
                                  fontSize: 14.sp,
                                ),
                              ),
                              Transform.scale(
                                scale: 1.2,
                                child: Radio<String>(
                                  value: sortFilter[index],
                                  groupValue: selectedSortOption,
                                  activeColor: primaryColor,
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedSortOption = value;
                                    });
                                    widget.onOrderFilterChanged(
                                        selectedSortOption!);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // SizedBox(height: 2.h),
                // Container(
                //   padding: EdgeInsets.fromLTRB(10.w, 0, 12.w, 0.h),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.pop(context);
                //         },
                //         child: selectorButton(
                //             textWhite, primaryColor, 'Cancel', primaryColor),
                //       ),
                //       SizedBox(width: 2.w),
                //       GestureDetector(
                //         onTap: () {
                //           Navigator.pop(context);
                //         },
                //         child: selectorButton(primaryColor, primaryColor,
                //             'Apply Filters', textWhite),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            widget.type ? 'Ongoing Orders' : 'Previous Orders',
            style: h4TextStyle.copyWith(color: textBlack),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
        GestureDetector(
          onTap: () {
            _showSortingBottomSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.2.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor, width: 0.2.h),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/sorting_icon.svg'),
                SizedBox(width: 2.w),
                Text(
                  'Sort',
                  style: body3TextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
