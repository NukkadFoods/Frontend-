import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/user/user_controller.dart';
import 'package:user_app/Controller/user/user_model.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';
import 'package:user_app/Widgets/customs/Profile/addressCard.dart';
import 'package:user_app/screens/locationSetupScreen.dart';
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';
import 'package:user_app/widgets/customs/toasts.dart';

class SavedAddresses extends StatefulWidget {
  final Function? onAddressSelected;
  final String? address;
  final String? saveAs;
  final LatLng? filterLocation;

  const SavedAddresses({
    super.key,
    this.onAddressSelected,
    this.address,
    this.saveAs,
    this.filterLocation,
  });

  @override
  State<SavedAddresses> createState() => _SavedAddressesState();
}

class _SavedAddressesState extends State<SavedAddresses> {
  UserModel? user;
  String? selectedAddress;
  String? selectedSaveAs;
  List<Address> addresses = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedAddress = widget.address;
    selectedSaveAs = widget.saveAs;
    getAddress();
  }

  void getAddress() async {
    var userId = SharedPrefsUtil().getString(AppStrings.userId) ?? "";
    var userResult =
        await UserController.getUserById(context: context, id: userId);

    userResult.fold((String text) {
      // context.showSnackBar(message: text);
    }, (UserModel userModel) {
      for (var address in userModel.user!.addresses!) {
        if (!(address.area == 'temp' && address.hint == "temp")) {
          addresses.add(address);
        }
      }
      setState(() {
        user = userModel;
      });
    });
  }

  Future<void> saveAddress(
      String address, String saveAs, double latitude, double longitude) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('CurrentAddress', address);
      await prefs.setString('CurrentSaveAs', saveAs);
      await prefs.setDouble('CurrentLatitude', latitude);
      await prefs.setDouble('CurrentLongitude', longitude);

      Toast.showToast(message: 'Address Selected!');
    } catch (e) {
      print("Error saving address: $e");
    }
  }

  void _selectAddress(int index) {
    setState(() {
      selectedAddress = user!.user!.addresses![index].address!;
      selectedSaveAs = user!.user!.addresses![index].saveAs ?? 'Home';
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Addresses',
            style: h4TextStyle.copyWith(
                color: isDarkMode ? textGrey2 : textBlack)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Stack(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Image.asset('assets/images/background.png'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: addresses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == addresses.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 2.1.w),
                                child: GestureDetector(
                                  onTap: () async {
                                    final data = await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                const LocationSetupScreen(
                                                  isAdd: true,
                                                )));
                                    if (data is Address) {
                                      await saveAddress(
                                        data.address!,
                                        data.saveAs ?? 'Home',
                                        data.latitude!,
                                        data.longitude!,
                                      );

                                      if (widget.onAddressSelected != null) {
                                        widget.onAddressSelected!({
                                          'address':
                                              data.address ?? 'No Address',
                                          'saveAs': data.saveAs ?? 'Home',
                                        });
                                      }
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 7.h,
                                      width: 82.w,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: textGrey3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                              Icons.add_circle_outline_outlined,
                                              size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Add Address',
                                            style: h5TextStyle.copyWith(
                                                color: isDarkMode
                                                    ? textGrey2
                                                    : textBlack),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Check if this is the selected address
                            bool isSelected = selectedAddress ==
                                user!.user!.addresses![index].address!;
                            if (isSelected) {
                              selectedIndex = index;
                            }

                            //for filtering new address based on current location of restaurant
                            if (widget.filterLocation != null) {
                              if (Geolocator.distanceBetween(
                                      widget.filterLocation!.latitude,
                                      widget.filterLocation!.longitude,
                                      user!.user!.addresses![index].latitude!,
                                      user!
                                          .user!.addresses![index].longitude!) >
                                  14000) {
                                return const SizedBox.shrink();
                              }
                            }

                            return GestureDetector(
                              onTap: () async {
                                await saveAddress(
                                  user!.user!.addresses![index].address!,
                                  user!.user!.addresses![index].saveAs ??
                                      'Home',
                                  user!.user!.addresses![index].latitude!,
                                  user!.user!.addresses![index].longitude!,
                                );
                                _selectAddress(index);
                                if (widget.onAddressSelected != null) {
                                  widget.onAddressSelected!({
                                    'address': selectedAddress ?? 'No Address',
                                    'saveAs': selectedSaveAs,
                                  });
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 1.h),
                                child: Material(
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      // Apply border if selected
                                      border: isSelected
                                          ? Border.all(
                                              color: isDarkMode
                                                  ? Colors.amber
                                                  : primaryColor,
                                              width: 2)
                                          : Border.all(
                                              color: textGrey3, width: 1),
                                    ),
                                    child: addressCard(
                                      'assets/icons/home_address_icon.svg',
                                      user!.user!.addresses![index].saveAs ??
                                          'Home',
                                      user!.user!.addresses![index].address ??
                                          'No Address',
                                      context,
                                      index,
                                      user,
                                      showDelete:
                                          user!.user!.addresses!.length != 1,
                                      onDelete: (address, saveAs) async {
                                        if (selectedAddress == address) {
                                          int newIndex =
                                              selectedIndex == 0 ? 1 : 0;
                                          await saveAddress(
                                            user!.user!.addresses![newIndex]
                                                .address!,
                                            user!.user!.addresses![newIndex]
                                                    .saveAs ??
                                                'Home',
                                            user!.user!.addresses![newIndex]
                                                .latitude!,
                                            user!.user!.addresses![newIndex]
                                                .longitude!,
                                          );
                                          _selectAddress(newIndex);
                                          if (widget.onAddressSelected !=
                                              null) {
                                            widget.onAddressSelected!({
                                              'address': selectedAddress ??
                                                  'No Address',
                                              'saveAs': selectedSaveAs,
                                            });
                                          }
                                        } else {
                                          if (selectedIndex > index) {
                                            await saveAddress(
                                              user!
                                                  .user!
                                                  .addresses![selectedIndex - 1]
                                                  .address!,
                                              user!
                                                      .user!
                                                      .addresses![
                                                          selectedIndex - 1]
                                                      .saveAs ??
                                                  'Home',
                                              user!
                                                  .user!
                                                  .addresses![selectedIndex - 1]
                                                  .latitude!,
                                              user!
                                                  .user!
                                                  .addresses![selectedIndex - 1]
                                                  .longitude!,
                                            );
                                            _selectAddress(selectedIndex - 1);
                                          } else {
                                            Navigator.of(context).pop();
                                          }
                                        }
                                        addresses.removeAt(index);
                                        user!.user!.addresses!.removeAt(index);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
