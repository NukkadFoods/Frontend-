import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/Profile/Menu/menu_model.dart';
import 'package:restaurant_app/Screens/Navbar/menuBody.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
import 'package:restaurant_app/Widgets/menu/menuItemCard.dart';
import 'package:sizer/sizer.dart';

class MenuItems extends StatefulWidget {
  MenuItems({
    Key? key,
    required this.categories,
    required this.subCategories,
    required this.menuItemsByCategory,
    required this.menuModel,
    required this.subCategoriesMap,
    required this.menuRefreshCallback,
  }) : super(key: key);
  final List<String> categories;
  final List<String> subCategories;
  final Map<String, List<MenuItemModel>> menuItemsByCategory;
  final FullMenuModel menuModel;
  final Map<String, List<String>> subCategoriesMap;
  final MenuRefreshCallback menuRefreshCallback;

  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> with TickerProviderStateMixin {
  late List<bool> isExpanded;
  late AnimationController animationController;

  _MenuItemsState();

  void _toggleExpand(int index) {
    setState(() {
      isExpanded[index] = !isExpanded[index];
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isExpanded = List.generate(widget.categories.length, (index) => false);
    });
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildCategoryList(index),
          separatorBuilder: (context, index) => Divider(),
          itemCount: widget.categories.length),
    );
  }

  Widget _buildCategoryList(int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _toggleExpand(index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.categories[index].replaceAll("_", " ")} (${widget.menuItemsByCategory[widget.categories[index]]!.length})',
                style: h6TextStyle,
              ),
              Icon(
                isExpanded[index]
                    ? Icons.arrow_drop_down
                    : Icons.keyboard_arrow_right,
                size: 30,
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animationController,
            curve: Curves.easeInOut,
          ),
          axisAlignment: 0.0,
          child: isExpanded[index] &&
                  widget.menuItemsByCategory[widget.categories[index]] != null
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, itemIndex) => MenuItemCard(
                        menuItemModel: widget.menuItemsByCategory[
                            widget.categories[index]]![itemIndex],
                        categories: widget.categories,
                        subCategories: widget.subCategories,
                        category: widget.categories[index],
                        subCategory: getSubCategory(index, itemIndex),
                        subCategoriesMap: widget.subCategoriesMap,
                        menuRefreshCallback: widget.menuRefreshCallback,
                      ),
                  separatorBuilder: (context, index) => SizedBox(height: 1.h),
                  itemCount: widget
                      .menuItemsByCategory[widget.categories[index]]!.length)
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  String getSubCategory(int index, int itemIndex) {
    String subCategory = "null";
    // List<String> subcategories =
    //     widget.subCategoriesMap[widget.categories[index]] ?? [];
    // List<String?> itemsID = widget
    //     .menuItemsByCategory[widget.categories[index]]!
    //     .map((e) => e.id)
    //     .toList();
    widget.menuModel.menuItems!.forEach((MenuCategory category) {
      if (category.category == widget.categories[index]) {
        category.subCategory?.forEach((SubCategory subcategories) {
          subcategories.menuItems?.forEach((MenuItemModel item) {
            if (item.id ==
                widget.menuItemsByCategory[widget.categories[index]]![itemIndex]
                    .id) {
              subCategory = subcategories.subCategoryName ?? "null";
            }
          });
        });
      }
    });
    // for (MenuCategory menuItem in widget.menuModel.menuItems!) {
    //   for (SubCategory subCategory in menuItem.subCategory!) {
    //     for (MenuItemModel item in subCategory.menuItems!) {
    //       if (item.id == widget.menuItemsByCategory[widget.categories[index]])
    //         print(subCategory.subCategoryName);
    //       return subCategory.subCategoryName ?? "null";
    //     }
    //   }
    // }
    return subCategory;
  }
}
