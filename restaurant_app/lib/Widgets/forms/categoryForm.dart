import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_controller.dart';
import 'package:restaurant_app/Screens/Navbar/menuBody.dart';
import 'package:restaurant_app/Widgets/buttons/addButton.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/navigation_extension.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/show_snack_bar_extension.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/menu/addImage.dart';
import 'package:restaurant_app/Widgets/menu/customInputField.dart';
import 'package:sizer/sizer.dart';

class CategoriesForm extends StatefulWidget {
  const  CategoriesForm({
    super.key,
    required this.categories,
    required this.menuRefreshCallback,
  });

  final List categories;
  final MenuRefreshCallback menuRefreshCallback;
  @override
  State<CategoriesForm> createState() => _CategoriesFormState();
}

class _CategoriesFormState extends State<CategoriesForm> {
  TextEditingController categoryName = TextEditingController();
  String? selectedCategory; // To store the currently selected value

  bool isAddCategoryLoaded = true;
  bool isCategoryImageUploaded = false;
  String? imageCategoryPath;

  void _handleImagePicked(bool isPicked, String? filePath) {
    setState(() {
      isCategoryImageUploaded = isPicked;
      imageCategoryPath = filePath;
    });
  }

  @override
  void dispose() {
    categoryName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              CustomInputField(
                  labelText: 'Category Name', controller: categoryName),
              SizedBox(
                height: 20,
              ),
              AddImage(
                isOptional: false,
                context: context,
                onFilePicked: _handleImagePicked,
                imagePath: imageCategoryPath,
                isImageUploaded: isCategoryImageUploaded,
              ),
              SizedBox(
                height: 20,
              ),
              isAddCategoryLoaded
                  ? AddButton(
                      onPressed: () async {
                        setState(() {
                          isAddCategoryLoaded = false;
                        });
                        if (categoryName.text.isNotEmpty &&
                            imageCategoryPath != null) {
                          if (!widget.categories.contains(
                              categoryName.text.replaceAll(" ", "_"))) {
                            String? uid =
                                SharedPrefsUtil().getString(AppStrings.userId);
                            if (uid != null) {
                              await MenuControllerClass.addCategory(
                                uid: uid,
                                url: imageCategoryPath!,
                                category:
                                    categoryName.text.replaceAll(" ", "_"),
                              ).then((_) {
                                setState(() {
                                  isAddCategoryLoaded = true;
                                });
                                context.pop();
                                widget.menuRefreshCallback();
                              });
                            } else {
                              setState(() {
                                isAddCategoryLoaded = true;
                              });
                              context.showSnackBar(
                                  message: 'User ID is not available');
                            }
                          } else {
                            setState(() {
                              isAddCategoryLoaded = true;
                            });
                            context.showSnackBar(
                                message: 'Category already exists');
                          }
                        } else {
                          setState(() {
                            isAddCategoryLoaded = true;
                          });
                          context.showSnackBar(
                              message: AppStrings.allFieldsRequired);
                        }
                      },
                    )
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
