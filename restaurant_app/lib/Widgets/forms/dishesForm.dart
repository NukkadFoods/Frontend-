import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_controller.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_model.dart';
import 'package:restaurant_app/Controller/Profile/Menu/save_menu_item.dart';
import 'package:restaurant_app/Controller/Profile/Menu/update_menu_item_model.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/Navbar/menuBody.dart';
import 'package:restaurant_app/Widgets/buttons/addButton.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/show_snack_bar_extension.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/menu/addImage.dart';
import 'package:restaurant_app/Widgets/menu/categories.dart';
import 'package:restaurant_app/Widgets/menu/customInputField.dart';
import 'package:restaurant_app/Widgets/toast.dart';

class DishesForm extends StatefulWidget {
  const DishesForm({
    super.key,
    required this.categories,
    required this.subCategories,
    required this.subCategoriesMap,
    // this.subCategory,
    this.menuItemModel,
    this.edit = false,
    this.selectedCategory,
    this.selectedSubCategory,
    this.selectedLabel,
    this.fullMenu,
    required this.menuRefreshCallback,
  });
  final List categories;
  final List<String> subCategories;
  // final String? subCategory;
  final MenuItemModel? menuItemModel;
  final bool edit;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String? selectedLabel;
  final Map<String, List> subCategoriesMap;
  final MenuRefreshCallback menuRefreshCallback;
  final Map? fullMenu;

  @override
  State<DishesForm> createState() => _DishesFormState();
}

class _DishesFormState extends State<DishesForm> {
  TextEditingController itemName = TextEditingController();
  TextEditingController basePrice = TextEditingController();
  TextEditingController timeToPrepare = TextEditingController();
  TextEditingController noOfServers = TextEditingController();
  // TextEditingController label = TextEditingController();

  String? selectedCategory;
  String? selectedSubCategory =
      "default"; //change it null to enable subcategories
  String? selectedLabel;
  String label = AppStrings.subCategory[0];
  bool isLoading = false;
  final List<bool> subCategoryCheck = [
    true,
    false,
    false,
    false,
    false,
  ];
  final List<String> subCategoryImage = [
    'assets/images/veg.jpeg',
    'assets/images/nonveg.jpeg',
    'assets/images/vegan.png',
    'assets/images/glutenfree.png',
    'assets/images/dairyfree.png'
  ];

  bool isDishImageUploaded = false;
  String? imageDishPath;
  _DishesFormState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // fetchCategories(); // Fetch categories when the form initializes
    // fetchSubCategories(); // Fetch categories when the form initializes

    widget.edit
        ? {
            print(widget.menuItemModel!.toJson()),
            setState(() {
              itemName.text = widget.menuItemModel!.menuItemName!;
              basePrice.text = widget.menuItemModel!.menuItemCost.toString();
              timeToPrepare.text =
                  widget.menuItemModel!.timeToPrepare.toString();
              noOfServers.text = widget.menuItemModel!.servingInfo!;
              selectedCategory = widget.selectedCategory!;
              selectedSubCategory = widget.selectedSubCategory!;
              selectedLabel = widget.menuItemModel!.label;
              for (int i = 0; i < subCategoryCheck.length; i++) {
                if (widget.selectedLabel == AppStrings.subCategory[i]) {
                  subCategoryCheck[i] = true;
                }
              }
              imageDishPath = widget.menuItemModel!.menuItemImageURL ?? "";
              isDishImageUploaded = true;
            })
          }
        : null;
  }

  void _handleImagePicked(bool isPicked, String? filePath) {
    setState(() {
      isDishImageUploaded = isPicked;
      imageDishPath = filePath;
    });
  }

  Future saveMenu() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_validateForm()) {
        if (widget.edit) {
          await MenuControllerClass.updateMenuItem(
            updateMenuItemModel: UpdateMenuItemModel(
              updatedata: widget.menuItemModel!.copyWith(
                menuItemName: itemName.text,
                menuItemCost: double.tryParse(basePrice.text) ?? 0.0,
                timeToPrepare: double.tryParse(timeToPrepare.text) ?? 0.0,
                inStock: true,
                servingInfo: noOfServers.text,
                label: selectedLabel,
                menuItemImageURL: imageDishPath ?? "",
              ),
            ),
            context: context,
            uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
            menuitemid: widget.menuItemModel!.id!,
            category: widget.selectedCategory!.replaceAll(" ", "_"),
            // subCategory: widget.subCategory ?? "null",
            subCategory: widget.selectedSubCategory!.replaceAll(" ", "_"),
          );
        } else {
          await MenuControllerClass.saveMenuItem(
            saveMenuItem: SaveMenuItem(
              uid: SharedPrefsUtil().getString(AppStrings.userId),
              category: selectedCategory!.replaceAll(" ", "_"),
              subCategory: selectedSubCategory!.replaceAll(" ", "_"),
              menuItem: SaveMenuItemModel(
                menuItemName: itemName.text,
                menuItemImageURL: imageDishPath ?? "",
                servingInfo: noOfServers.text,
                menuItemCost: double.tryParse(basePrice.text) ?? 0.0,
                inStock: true,
                label: selectedLabel,
                timeToPrepare: double.tryParse(timeToPrepare.text) ?? 0.0,
              ),
            ),
            context: context,
          );
          if (widget.fullMenu != null) {
            final timetoprepare = MenuControllerClass.getAveragePrepTime(
                widget.fullMenu!,
                initialTime: double.tryParse(timeToPrepare.text));
            LoginController.updateRestaurantDataByID(
                uid: SharedPrefsUtil().getString(AppStrings.userId)!,
                data: {"timetoprepare": timetoprepare.toStringAsFixed(2)},
                context: context,
                showToast: false);
          }
        }
        setState(() {
          isLoading = false;
        });
        // context.pop(); // Close the form after successful submission
        // Notify the menu screen that a new item has been added or updated
        Navigator.pop(context, true);
        widget.menuRefreshCallback();
      } else {
        setState(() {
          isLoading = false;
        });
        context.showSnackBar(message: AppStrings.allFieldsRequired);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      context.showSnackBar(message: 'Failed to add dish: ${e.toString()}');
    }
  }

  bool _validateForm() {
    return itemName.text.isNotEmpty &&
        basePrice.text.isNotEmpty &&
        timeToPrepare.text.isNotEmpty &&
        noOfServers.text.isNotEmpty &&
        selectedCategory != null &&
        selectedSubCategory != null &&
        selectedLabel != null;
  }

  changeSubCategoryCheck(int index) {
    setState(() {
      for (int i = 0; i < subCategoryCheck.length; i++) {
        subCategoryCheck[i] = i == index ? true : false;
      }
      selectedLabel = AppStrings.subCategory[index];
    });
  }

  void addCategory(bool isCategory) {
    if (!isCategory && selectedCategory == null) {
      Toast.showToast(message: "Please Select Category first", isError: true);
      return;
    }
    TextEditingController categoryName = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(10),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add ${isCategory ? "Category" : "Sub-Category in $selectedCategory"}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: categoryName,
                decoration: InputDecoration(
                    labelText: "* ${isCategory ? "" : "Sub-"}Category Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(width: 1))),
              ),
              Text(
                "Note: The ${isCategory ? "" : "Sub-"}Category Name can't be changed after creation",
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        if (categoryName.text.isNotEmpty) {
                          final newName =
                              categoryName.text.trim().replaceAll(" ", "_");
                          if (isCategory) {
                            if (!widget.categories.contains(newName)) {
                              String? uid = SharedPrefsUtil()
                                  .getString(AppStrings.userId);
                              if (uid != null) {
                                final added =
                                    await MenuControllerClass.addCategory(
                                        uid: uid, url: "no", category: newName);
                                await MenuControllerClass.addSubCategory(
                                  uid: uid,
                                  category: newName,
                                  subCategory: "default",
                                );
                                if (added) {
                                  widget.categories.add(newName);
                                  widget.subCategoriesMap[newName] = [];
                                  setState(() {});
                                  widget.menuRefreshCallback();
                                }
                                Navigator.of(context).pop();
                              }
                            }
                          }
                          // else {
                          //   if (!(widget.subCategoriesMap[selectedCategory] ??
                          //           [])
                          //       .contains(newName)) {
                          //     String? uid = SharedPrefsUtil()
                          //         .getString(AppStrings.userId);
                          //     if (uid != null) {
                          //       final added =
                          //           await MenuControllerClass.addSubCategory(
                          //         uid: uid,
                          //         category:
                          //             selectedCategory!.replaceAll(" ", "_"),
                          //         subCategory: newName,
                          //       );
                          //       if (added) {
                          //         widget.subCategoriesMap[selectedCategory]!
                          //             .add(newName);
                          //         setState(() {});
                          //         widget.menuRefreshCallback();
                          //       }
                          //       Navigator.of(context).pop();
                          //     }
                          //   }
                          // }
                        }
                      },
                      child: Text("Add")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Dishes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < AppStrings.subCategory.length; i++)
                      _buildSubCategoryWidget(index: i),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CustomInputField(labelText: 'Item Name', controller: itemName),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFCACACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item Price', style: h5TextStyle),
                    SizedBox(height: 20),
                    Text(
                      'Enter the price details of the item',
                      style: TextStyle(color: Color(0xFFCACACA)),
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                      labelText: 'Base Price',
                      controller: basePrice,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                        labelText: 'Preparation Time ( in mins )',
                        controller: timeToPrepare,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFCACACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Serving Information', style: h5TextStyle),
                    SizedBox(height: 20),
                    Text(
                      'Enter the size and quantity of the item',
                      style: TextStyle(color: Color(0xFFCACACA)),
                    ),
                    SizedBox(height: 20),
                    CustomInputField(
                        labelText: 'No of Serves', controller: noOfServers),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFCACACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: h5TextStyle),
                    SizedBox(height: 20),
                    Text(
                      'Define the category of the item',
                      style: TextStyle(color: Color(0xFFCACACA)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DropdownButton<String>(
                              elevation: 3,
                              value: selectedCategory,
                              hint: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Choose item category'),
                              ),
                              onChanged: (String? newValue) {
                                if (newValue == "Add Category") {
                                  addCategory(true);
                                } else {
                                  setState(() {
                                    selectedCategory = newValue;
                                    // selectedSubCategory = null;
                                  });
                                }
                              },
                              isExpanded: true,
                              underline: Container(),
                              items: widget.categories.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Text(item.replaceAll("_", " ")),
                                      ),
                                    );
                                  }).toList() +
                                  [
                                    DropdownMenuItem<String>(
                                      value: 'Add Category',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add),
                                            Text("Add Category"),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Container(
              //   padding: EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Color(0xFFCACACA)),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text('Sub-Category', style: h5TextStyle),
              //       SizedBox(height: 20),
              //       Text(
              //         'Define the sub-category of the item',
              //         style: TextStyle(color: Color(0xFFCACACA)),
              //       ),
              //       SizedBox(height: 20),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: Container(
              //               decoration: BoxDecoration(
              //                 border:
              //                     Border.all(color: Colors.grey, width: 1.0),
              //                 borderRadius: BorderRadius.circular(8.0),
              //               ),
              //               child: DropdownButton<String>(
              //                 elevation: 3,
              //                 value: selectedSubCategory,
              //                 hint: Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Text('Choose item sub-category'),
              //                 ),
              //                 onChanged: (String? newValue) {
              //                   if (newValue == 'Add Sub-Category') {
              // addCategory(false);
              //                   } else {
              //                     setState(() {
              //                       selectedSubCategory = newValue;
              //                     });
              //                   }
              //                 },
              //                 isExpanded: true,
              //                 underline: Container(),
              //                 items:
              //                     (widget.subCategoriesMap[selectedCategory] ??
              //                                 [])
              //                             .map((item) {
              //                           return DropdownMenuItem<String>(
              //                             value: item,
              //                             child: Padding(
              //                               padding: EdgeInsets.symmetric(
              //                                   horizontal: 10.0),
              //                               child:
              //                                   Text(item.replaceAll("_", " ")),
              //                             ),
              //                           );
              //                         }).toList() +
              //                         [
              //                           DropdownMenuItem<String>(
              //                             value: 'Add Sub-Category',
              //                             child: Padding(
              //                               padding: EdgeInsets.symmetric(
              //                                   horizontal: 10.0),
              //                               child: Row(
              //                                 mainAxisSize: MainAxisSize.min,
              //                                 children: [
              //                                   Icon(Icons.add),
              //                                   Text("Add Sub-Category"),
              //                                 ],
              //                               ),
              //                             ),
              //                           )
              //                         ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 20),
              // AddImage(),
              AddImage(
                  isOptional: false,
                  context: context,
                  onFilePicked: _handleImagePicked,
                  isImageUploaded: isDishImageUploaded,
                  imagePath: imageDishPath),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : AddButton(
                      onPressed: saveMenu,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryWidget({required int index}) => Row(
        children: [
          Category(
            imagePath: subCategoryImage[index],
            label: AppStrings.subCategory[index],
            isSelected: selectedLabel == AppStrings.subCategory[index],
            onTap: () {
              changeSubCategoryCheck(index);
              // setState(() {
              //   for (int i = 0; i < subCategoryCheck.length; i++) {
              //     subCategoryCheck[i] = i == index ? true : false;
              //   }
              //   print(subCategoryCheck);
              //   selectedLabel = AppStrings.subCategory[index];
              // });
            },
          ),
          SizedBox(width: 10),
        ],
      );
}
