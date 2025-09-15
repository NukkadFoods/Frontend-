import 'package:flutter/material.dart';
import 'package:user_app/Controller/food/model/fetch_all_restaurants_model.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class SortBottomSheet extends StatefulWidget {
  final FetchAllRestaurantsModel restaurantsModel;
  final Function(String value) onChanged;
  final String currentSortSetting;
  const SortBottomSheet({
    super.key,
    required this.restaurantsModel,
    required this.onChanged,
    required this.currentSortSetting,
  });
  @override
  _SortBottomSheetState createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String? selectedOption = 'Delivery time'; // Default selected option
  @override
  void initState() {
    super.initState();
    if (widget.currentSortSetting.isNotEmpty) {
      selectedOption = widget.currentSortSetting;
    }
  }

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sort', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2: textBlack)),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildRadioOption('Delivery time',isdarkmode),
            _buildRadioOption('Rating: High to low',isdarkmode),
            _buildRadioOption('Rating: Low to high',isdarkmode),
            _buildRadioOption('Relevance',isdarkmode),
            // _buildRadioOption('Cost: Low to high'),
            // _buildRadioOption('Cost: High to low'),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedOption = null; // Clear selection
                      });
                    },
                    child: const Text('    Clear All    ',
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: textWhite,

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(4), // Button border radius
                        // Primary color border
                      ), // Apply primary color
                    ),
                    onPressed: () {
                      switch (selectedOption!) {
                        case 'Delivery time':
                          widget.restaurantsModel.restaurants!.sort((a, b) =>
                              getDistance(a.distanceFromUser!)
                                  .compareTo(getDistance(b.distanceFromUser!)));
                          widget.onChanged(selectedOption!);
                          break;
                        case 'Rating: High to low':
                          widget.restaurantsModel.restaurants!.sort((b, a) => a
                              .getAverageRating()
                              .compareTo(b.getAverageRating()));
                          widget.onChanged(selectedOption!);
                          break;
                        case 'Rating: Low to high':
                          widget.restaurantsModel.restaurants!.sort((a, b) => a
                              .getAverageRating()
                              .compareTo(b.getAverageRating()));
                          widget.onChanged(selectedOption!);
                          break;
                        default:
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('    Apply    '),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getDistance(String distance) {
    double distanceKm = 0.0;
    final String temp = distance.split(' ')[0];
    if (temp.endsWith('k')) {
      distanceKm = double.tryParse(temp.split('k')[0]) ?? 0.0;
      distanceKm = distanceKm * 1000;
    } else {
      distanceKm = double.tryParse(distance.split(' ')[0]) ?? 0.0;
    }
    return distanceKm;
  }

  // Helper method to create radio options with radio buttons aligned to the right
  Widget _buildRadioOption(String title,bool isdarkmode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title,style: TextStyle(color: isdarkmode ? textGrey2: textBlack),)), // Text on the left
          Radio<String>(
            value: title,
            groupValue: selectedOption,
            activeColor: primaryColor,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          ), // Radio button on the right
        ],
      ),
    );
  }
}

Future<void> showSortBottomSheet(
    BuildContext context,
    FetchAllRestaurantsModel model,
    String currentSortSetting,
    Function(String value) onChanged) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SortBottomSheet(
      restaurantsModel: model,
      onChanged: onChanged,
      currentSortSetting: currentSortSetting,
    ),
  );
}
