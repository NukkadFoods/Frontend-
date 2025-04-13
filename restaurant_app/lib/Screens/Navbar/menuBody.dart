import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_controller.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_model.dart';
import 'package:restaurant_app/Controller/Profile/profile_controller.dart';
import 'package:restaurant_app/Screens/Wallet/viewEarningsScreen.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/shared_preferences.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/customs/MenuBody/menuAppBar.dart';
import 'package:restaurant_app/Widgets/customs/MenuBody/menuSearchBar.dart';
import 'package:restaurant_app/Widgets/menu/menuItemCard.dart';

typedef MenuRefreshCallback = void Function();

class MenuBody extends StatefulWidget {
  const MenuBody({super.key});

  @override
  State<MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {
  bool isMenuLoaded = false;
  Map? fullMenu;
  CategoryMenuModel? categoryMenu;
  SimpleMenuModel? simpleMenu;
  List<MenuItemModel>? filteredMenuItems;
  // List<String> subCategoryNames = [];
  List<MenuItemModel> menuItemsList = [];
  Map<String, List<MenuItemModel>> menuItemsByCategory = {};
  List categories = [];
  List<String> subCategories = [];
  int selectedCategory = 0;
  String selectedSubCategory = 'default';
  final Map<String, List> subCategoryMap = {};

  Future<void> getMenu({String? category, String? subCategory}) async {
    setState(() {
      menuItemsList = [];
      menuItemsByCategory = {};
      categories = [];
      subCategories = [];
      isMenuLoaded = false;
    });

    var result = await MenuControllerClass.getMenuItems(
      context: context,
      uid: SharedPrefsUtil().getString(AppStrings.userId)!,
      category: category,
      subCategory: subCategory,
    );

    result.fold(
      (String errorMessage) {
        // context.showSnackBar(message: errorMessage);
      },
      (Map menuModel) {
        fullMenu = menuModel;
        // _processFullMenu();
        categories = menuModel.keys.toList();
        // subCategories = fullMenu!.menuItems!
        //     .expand((item) => item.subCategory!)
        //     .map((subItem) => subItem.subCategoryName!)
        //     .toSet()
        //     .toList();
        // updateTimeToPrepareForRestaurant(fullMenuModel: menuModel);
        for (var cat in menuModel.entries) {
          subCategoryMap[cat.key] = cat.value.keys.toList();
        }
        // if (categories.isNotEmpty &&
        //     subCategoryMap[categories[0]]!.isNotEmpty) {
        //   selectedSubCategory = subCategoryMap[categories[0]]![0];
        // }
        isMenuLoaded = true;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // void _processFullMenu() {
  //   if (fullMenu!.menuItems != null) {
  //     for (var menuItem in fullMenu!.menuItems!) {
  //       if (menuItem.category != null && menuItem.subCategory != null) {
  //         String category = menuItem.category!;
  //         subCategoryMap[category] = [];
  //         subCategoryMap[category]!.addAll(menuItem.subCategory!.isEmpty
  //             ? []
  //             : menuItem.subCategory!.map((subCategory) =>
  //                 subCategory.subCategoryName!.isEmpty
  //                     ? ""
  //                     : subCategory.subCategoryName!));
  //         if (!menuItemsByCategory.containsKey(category)) {
  //           menuItemsByCategory[category] = [];
  //         }
  //         menuItemsByCategory[category]!.addAll(menuItem.subCategory!
  //             .expand((subCategory) => subCategory.menuItems!));
  //       }
  //     }
  //     categories = menuItemsByCategory.keys.toList();
  //     // getSubAndMenuItemCategoryNames(menuItems: fullMenu!);
  //   }
  // }

  void updateTimeToPrepareForRestaurant(
      {required FullMenuModel fullMenuModel}) async {
    bool success = await LoginController.updateRestaurantByIDtimetoprepare(
        uid: SharedPrefsUtil().getString(AppStrings.userId) ?? "",
        timeToPrepare: calculateAverageTimeToPrepare(fullMenuModel),
        context: null);
    if (success) {
      // Handle success scenario, e.g., show success message
      print('Restaurant details updated successfully');
    } else {
      // Handle failure scenario
      print('Failed to update restaurant details.');
    }
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              top: 10,
              child: Image.asset(
                'assets/images/otpbg.png',
                fit: BoxFit.cover,
              )),
          RefreshIndicator(
            color: primaryColor,
            onRefresh: () {
              setState(() {
                isMenuLoaded = false;
              });
              return getMenu();
            },
            child: SafeArea(
              child: buildMenuBody(),
            ),
          ),
        ]));
  }

  void _handleSearchInput(String input) {
    // Handle the input text here
    print("Received search input: $input");
  }

  Widget buildMenuBody() {
    return Column(
      children: [
        MenuAppBar(
          categories: categories,
          subCategories: subCategories,
          subCategoriesMap: subCategoryMap,
          menuRefreshCallback: getMenu,
          fullMenu: fullMenu ?? {},
        ),
        MenuSearchBar(
          onTextChanged: _handleSearchInput,
        ),
        Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: !isMenuLoaded
                  ? Center(child: CircularProgressIndicator())
                  : fullMenu == null || categories.isEmpty
                      ? Center(child: Text(AppStrings.noItemsFound))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownMenu(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.start,
                                initialSelection: 0,
                                trailingIcon:
                                    Icon(Icons.arrow_drop_down, size: 30),
                                onSelected: (value) => setState(() {
                                      selectedCategory = value!;
                                    }),
                                menuStyle: MenuStyle(
                                    padding: const WidgetStatePropertyAll(
                                        EdgeInsets.all(0)),
                                    minimumSize: const WidgetStatePropertyAll(
                                        Size.zero)),
                                // trailingIcon: Icon(Icons.keyboard_arrow_down),
                                inputDecorationTheme: InputDecorationTheme(
                                    border: InputBorder.none, isDense: true),
                                dropdownMenuEntries:
                                    List.generate(categories.length, (index) {
                                  return DropdownMenuEntry(
                                      value: index,
                                      label: categories[index]
                                          .toString()
                                          .replaceAll("_", " ")
                                          .capitalize());
                                })),
                            // if (fullMenu![categories[selectedCategory]]
                            //     .isNotEmpty)
                            //   DropdownMenu(
                            //       textStyle: TextStyle(
                            //           fontWeight: FontWeight.w500,
                            //           color: const Color.fromARGB(255, 128, 127, 127)),
                            //       textAlign: TextAlign.start,
                            //       initialSelection: 0,
                            //       trailingIcon:
                            //           Icon(Icons.arrow_drop_down, size: 30),
                            //       onSelected: (value) => setState(() {
                            //             selectedSubCategory = subCategoryMap[
                            //                     categories[selectedCategory]]![
                            //                 value!];
                            //           }),
                            //       menuStyle: MenuStyle(
                            //           padding: const WidgetStatePropertyAll(
                            //               EdgeInsets.all(0)),
                            //           minimumSize: const WidgetStatePropertyAll(
                            //               Size.zero)),
                            //       // trailingIcon: Icon(Icons.keyboard_arrow_down),
                            //       inputDecorationTheme: InputDecorationTheme(
                            //           border: InputBorder.none, isDense: true),
                            //       dropdownMenuEntries: List.generate(
                            //           subCategoryMap[
                            //                   categories[selectedCategory]]!
                            //               .length, (index) {
                            //         final subCats = subCategoryMap[
                            //             categories[selectedCategory]]!;
                            //         return DropdownMenuEntry(
                            //             value: index,
                            //             label: subCats[index]
                            //                 .toString()
                            //                 .replaceAll("_", " "));
                            //       })),
                            Expanded(
                              child: ListView.builder(
                                  itemCount:
                                      (fullMenu![categories[selectedCategory]]
                                                  ['default'] ??
                                              [])
                                          .length,
                                  itemBuilder: (context, index) => MenuItemCard(
                                        menuItemModel: MenuItemModel.fromJson(
                                            fullMenu![categories[
                                                    selectedCategory]]
                                                ['default'][index]),
                                        categories: categories,
                                        subCategories: subCategories,
                                        category: categories[selectedCategory],
                                        // subCategory: selectedSubCategory,
                                        subCategory: 'default',
                                        subCategoriesMap: subCategoryMap,
                                        menuRefreshCallback: getMenu,
                                      )),
                            )
                          ],
                        )
              // : MenuItems(
              //     categories: categories,
              //     subCategories: subCategories,
              //     // menuItemsByCategory: menuItemsByCategory,
              //     menuItemsByCategory: _buildMenuItemsByCategory(),
              //     menuModel: fullMenu!,
              //     subCategoriesMap: subCategoryMap,
              //     menuRefreshCallback: getMenu,
              //   ),
              ),
        ),
      ],
    );
  }

  // Map<String, List<MenuItemModel>> _buildMenuItemsByCategory() {
  //   Map<String, List<MenuItemModel>> menuItemsByCategory = {};

  //   if (fullMenu != null ) {
  //     for (var menuItem in fullMenu!.menuItems!) {
  //       if (menuItem.category != null && menuItem.subCategory != null) {
  //         String category = menuItem.category!;
  //         if (!menuItemsByCategory.containsKey(category)) {
  //           menuItemsByCategory[category] = [];
  //         }
  //         menuItemsByCategory[category]!.addAll(menuItem.subCategory!
  //             .expand((subCategory) => subCategory.menuItems!));
  //       }
  //     }
  //   }

  //   return menuItemsByCategory;
  // }

  // String getSubCategory(int index, int itemIndex) {
  //   String subCategory = "null";
  //   fullMenu!.menuItems!.forEach((MenuCategory category) {
  //     if (category.category == categories[index]) {
  //       category.subCategory?.forEach((SubCategory subcategories) {
  //         subcategories.menuItems?.forEach((MenuItemModel item) {
  //           if (item.id ==
  //               _buildMenuItemsByCategory()[categories[index]]![itemIndex].id) {
  //             subCategory = subcategories.subCategoryName ?? "null";
  //           }
  //         });
  //       });
  //     }
  //   });
  //   return subCategory;
  // }
}
