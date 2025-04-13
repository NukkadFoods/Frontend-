import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Controller/food/food_controller.dart';
import 'package:user_app/Controller/food/model/allmenu_model.dart';

import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<MenuResponse> menuItems;

  @override
  void initState() {
    super.initState();
    menuItems = FoodController().fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pure Veg Items'),
      ),
      body: FutureBuilder<MenuResponse>(
        future: menuItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.menuItems.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.menuItems.length,
              itemBuilder: (context, index) {
                final menu = snapshot.data!.menuItems[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: menu.menuItemList.map((category) {
                    return Column(
                      children: category.subCategory.map((subCategory) {
                        return Column(
                          children: subCategory.menuItems.map((menuItem) {
                            return menuItem.label == 'Veg'
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: textWhite,
                                      height: 10.h,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                  'assets/images/veg.jpeg'),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Image.network(
                                                menuItem.menuItemImageURL,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                            menuItem.menuItemName,
                                            style: h6TextStyle,
                                          ),
                                          subtitle: Text(
                                              '₹${menuItem.menuItemCost.toStringAsFixed(2)}',
                                              style: body4TextStyle),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(child: const SizedBox( child: Text('no',style: TextStyle(color: textBlack),),));
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}