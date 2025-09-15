import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/widgets/constants/colors.dart';

import '../Controller/food/model/fetch_all_restaurants_model.dart'; // Replace with actual primary color import

void showFilterModal(
  BuildContext context, {
  required FetchAllRestaurantsModel restaurantsModel,
  required Function(String value) onChanged,
  required Map currentFilters,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return FilterModalSheet(
        restaurantsModel: restaurantsModel,
        onChanged: onChanged,
        currentFilters: currentFilters,
      );
    },
  );
}

// StatefulWidget for the Bottom Sheet
class FilterModalSheet extends StatefulWidget {
  const FilterModalSheet(
      {super.key,
      required this.restaurantsModel,
      required this.onChanged,
      required this.currentFilters});
  final FetchAllRestaurantsModel restaurantsModel;
  final Function(String value) onChanged;
  final Map currentFilters;

  @override
  _FilterModalSheetState createState() => _FilterModalSheetState();
}

class _FilterModalSheetState extends State<FilterModalSheet> {
  Map currentFilters = {};
  final List<String> cuisines = [
    'Chinese',
    'Thai',
    'Italian',
    'North Indian',
    'South Indian',
    'Chaat',
    'Mughlai',
    'Continental',
    'Bengali',
    'Fast Food',
    'Tandoori'
  ];

  final List<double> distanceOptions = [1, 5, 10];
  final List<double> deliveryTimes = [30, 45, 60];
  final List<double> ratings = [4.5, 4, 3.5, 3];
  // final List<String> costOptions = [
  //   ' 300- 600',
  //   'Greater than 600',
  //   'less than 300'
  // ];

  final List<String> selectedFilters = [];
  String selectedFilter = 'Cuisine';

  // Method to build the right-side list based on the selected filter
  List<Widget> buildRightSideList() {
    List currentList;
    String suffix = '';
    String prefix = '';
    switch (selectedFilter) {
      case 'Distance':
        currentList = distanceOptions;
        prefix = "Max ";
        suffix = " km";
        break;
      case 'Delivery Time':
        currentList = deliveryTimes;
        prefix = "Max ";
        suffix = " min";
        break;
      case 'Rating':
        currentList = ratings;
        suffix = "+ Stars";
        break;
      // case 'Cost for two':
      //   currentList = costOptions;
      //   break;
      default:
        currentList = cuisines;
        break;
    }
    if (currentList != cuisines) {
      return currentList
          .map((item) => RadioListTile(
              activeColor: colorSuccess,
              controlAffinity: ListTileControlAffinity.trailing,
              title: Text(
                  "$prefix${selectedFilter == "Rating" ? item : item.toInt()}$suffix"),
              value: item,
              groupValue: currentFilters[selectedFilter],
              onChanged: (value) {
                currentFilters[selectedFilter] = item;
                setState(() {});
              }))
          .toList();
    } else {
      return currentList
          .map((item) => CheckboxListTile(
                activeColor: colorSuccess,
                title: Text(item),
                value: currentFilters[selectedFilter].contains(item),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      currentFilters[selectedFilter].add(item);
                    } else {
                      currentFilters[selectedFilter].remove(item);
                    }
                  });
                },
              ))
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    currentFilters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 500,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                // Left Side Menu (Filter Types)
                SizedBox(
                  width: 110,
                  child: ListView(
                    children: [
                      buildFilterButton("Cuisine", selectedFilter == "Cuisine",
                          () {
                        setState(() {
                          selectedFilter = "Cuisine";
                        });
                      }),
                      buildFilterButton(
                          "Distance", selectedFilter == "Distance", () {
                        setState(() {
                          selectedFilter = "Distance";
                        });
                      }),
                      buildFilterButton(
                          "Delivery\nTime", selectedFilter == "Delivery Time",
                          () {
                        setState(() {
                          selectedFilter = "Delivery Time";
                        });
                      }),
                      buildFilterButton("Rating", selectedFilter == "Rating",
                          () {
                        setState(() {
                          selectedFilter = "Rating";
                        });
                      }),
                      // buildFilterButton(
                      //     "Cost for two", selectedFilter == "Cost for two", () {
                      //   setState(() {
                      //     selectedFilter = "Cost for two";
                      //   });
                      // }),
                    ],
                  ),
                ),
                SizedBox(
                  width: 1.w,
                ),
                const VerticalDivider(width: 1),
                // Right Side Filters (List based on selected filter)
                Expanded(
                  child: ListView(
                    children: buildRightSideList(),
                  ),
                ),
              ],
            ),
          ),
          // Bottom buttons (Clear and Apply)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentFilters.forEach((key, value) {
                        currentFilters[key] = null;
                      });
                      currentFilters["Cuisine"] = [];
                    });
                  },
                  child: const Text(
                    "Clear Filters",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textWhite),
                  onPressed: () {
                    currentFilters.forEach((key, value) {
                      widget.currentFilters[key] = value;
                    });
                    print(widget.currentFilters);
                    widget.onChanged("");
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Filter Button Design for Left Panel
  Widget buildFilterButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 1.w),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(minHeight: 45),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
