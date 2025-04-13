import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/Food/searchBar.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class SectionGrid extends StatefulWidget {
  final String headerText;
  final List <String> names;
  final List <String>images;
  final List<Restaurants> restaurantsList;
  final List<Restaurants>? favoriteRestaurants;
  final String? text; 

  const SectionGrid({
    super.key,
    required this.headerText,
    required this.names,
    required this.images,
    required this.restaurantsList,
    this.favoriteRestaurants,
    this.text,
  });

  @override
  _SectionGridState createState() => _SectionGridState();
}

class _SectionGridState extends State<SectionGrid> {
  
void routsearchscreen(String text){
   Navigator.of(context).push( transitionToNextScreen(MySearchBar(
                    restaurantsList:
                        widget.restaurantsList,
                    favoriteRestaurants: widget.favoriteRestaurants,
                    initialText: text,
                  
                  )));
}
  @override
  Widget build(BuildContext context) {
      bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: textGrey2, width: 0.2.h),
          bottom: BorderSide(color: textGrey2, width: 0.2.h),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.headerText.toUpperCase(),
            style:isdarkmode ? titleTextStyle.copyWith(fontSize: 13.sp,color: textGrey2): titleTextStyle.copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 21.h, // Fixed height for the grid
            child: GridView.builder(
              scrollDirection: Axis.horizontal, // Enable scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 4 items per row
              ),
              itemCount: 22, // Increase item count to 22
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    routsearchscreen(widget.names[index % widget.names.length],);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        widget.images[index % widget.images.length], // Prevent out of bounds
                        height: 5.5.h,
                      ),
                      Text(
                        widget.names[index % widget.names.length], // Prevent out of bounds
                        style: body6TextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                          color: isdarkmode ? textGrey2 : textBlack
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
