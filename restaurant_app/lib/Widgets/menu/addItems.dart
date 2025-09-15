import 'package:flutter/material.dart';
import 'package:restaurant_app/Screens/Navbar/menuBody.dart';
import 'package:restaurant_app/Widgets/buttons/cancelButton.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/customs/MenuBody/menuItems.dart';
import 'package:restaurant_app/Widgets/forms/categoryForm.dart';
import 'package:restaurant_app/Widgets/forms/dishesForm.dart';
import 'package:restaurant_app/Widgets/forms/subCategoryForm.dart';

class AddItems extends StatelessWidget {
  const AddItems({
    super.key,
    required this.categories,
    required this.subCategories,
    required this.closeBottomSheet,
    required this.subCategoriesMap,
    required this.menuRefreshCallback,
  });
  final List categories;
  final List<String> subCategories;
  final VoidCallback closeBottomSheet;
  final Map<String, List> subCategoriesMap;
  final MenuRefreshCallback menuRefreshCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              'Add Item or Category',
              style: h5TextStyle,
            ),
            SizedBox(
              height: 20,
            ),
            MenuItem(
              itemName: 'Add Dish',
              screen: DishesForm(
                  categories: categories,
                  subCategories: subCategories,
                  subCategoriesMap: subCategoriesMap,
                  menuRefreshCallback: menuRefreshCallback),
              closeBottomSheet: closeBottomSheet,
            ),
            SizedBox(
              height: 20,
            ),
            MenuItem(
              itemName: 'Add Category',
              screen: CategoriesForm(
                categories: categories,
                menuRefreshCallback: menuRefreshCallback,
              ),
              closeBottomSheet: closeBottomSheet,
            ),
            SizedBox(
              height: 20,
            ),
            MenuItem(
              itemName: 'Add Sub-Category',
              screen: SubCategoriesForm(
                categories: categories,
                subCategoriesMap: subCategoriesMap,
                menuRefreshCallback: menuRefreshCallback,
              ),
              closeBottomSheet: closeBottomSheet,
            ),
            SizedBox(
              height: 20,
            ),
            Align(alignment: Alignment.centerRight, child: CancelButton()),
          ],
        ),
      ),
    );
    
  }
}
