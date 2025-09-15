import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/screens/Profile/savedAddresses.dart';

class AddressWidget extends StatefulWidget {
  final String address;
  final String saveAs;
  final LatLng filterLocation;
  final VoidCallback onAddressSelected;
  final int prepTime;

  const AddressWidget({
    super.key,
    required this.address,
    required this.saveAs,
    required this.onAddressSelected,
    required this.filterLocation,
    required this.prepTime,
  });

  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  String selectedSaveAs = '';
  String selectedAddress = '';
  String prefsSaveAs = '';
  String prefsAddress = '';

  @override
  void initState() {
    super.initState();
    getAddressSelected(); // Fetch address type and details initially
  }

  // Function to get the selected address type and details from SharedPreferences
  Future<void> getAddressSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefsAddress = prefs.getString('CurrentAddress') ?? "";
      prefsSaveAs = prefs.getString('CurrentSaveAs') ?? "";
    });
  }

  void handleAddressSelection(Map<String, String?> addressData) {
    String address = addressData['address']!;
    String saveAs = addressData['saveAs']!;
    setState(() {
      selectedAddress = address;
      selectedSaveAs = saveAs;
    });
    getAddressSelected();
    widget.onAddressSelected();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    // Use savedAs and address from parent widget if both prefs are empty
    String displaySaveAs = selectedSaveAs.isNotEmpty
        ? selectedSaveAs
        : (prefsSaveAs.isNotEmpty ? prefsSaveAs : widget.saveAs);
    String displayAddress = selectedAddress.isNotEmpty
        ? selectedAddress
        : (prefsAddress.isNotEmpty ? prefsAddress : widget.address);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: textGrey2,
          width: 0.2.h,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/location_pin_icon.svg',
              height: 3.5.h,
              color: primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displaySaveAs,
                        style: h5TextStyle.copyWith(
                            fontSize: 13.sp,
                            color: isdarkmode ? textGrey2 : textBlack),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedAddresses(
                                onAddressSelected: handleAddressSelection,
                                address: prefsAddress,
                                saveAs: prefsSaveAs,
                                filterLocation: widget.filterLocation,
                              ),
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/icons/dropdown_icon.svg',
                          height: 3.5.h,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    displayAddress,
                    style: body6TextStyle.copyWith(
                        color: isdarkmode ? textGrey2 : textBlack),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
                height: 4.h,
                width: 6.w,
                child: VerticalDivider(color: textGrey2, thickness: 0.5.w)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Est. Pickup in',
                  style: body6TextStyle.copyWith(
                      color: isdarkmode ? textGrey2 : textBlack),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.prepTime} mins',
                  style: h6TextStyle.copyWith(
                      fontSize: 10.sp,
                      color: isdarkmode ? textGrey2 : textBlack),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
