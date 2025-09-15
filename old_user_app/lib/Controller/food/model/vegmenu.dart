import 'dart:convert';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_app/Controller/food/model/allmenu_model.dart';
import 'package:http/http.dart' as http;
import 'package:user_app/widgets/constants/shared_preferences.dart';
import 'package:user_app/widgets/constants/strings.dart';

class Vegmenu {
  static late MenuResponse menuResponse;
  // static String baseUrl = dotenv.env['BASE_URL']!;
  static String baseUrl = SharedPrefsUtil().getString('base_url')!;
  static List<String> items = [];
  static bool running = false;
  static void getAllVegMenuItems() async {
    print(items);
    if (items.isNotEmpty || running) {
      return;
    }
    running = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu/fetchAllItems'),
          headers: {AppStrings.contentType: AppStrings.applicationJson});
      if (response.statusCode == 200) {
        // menuResponse = MenuResponse.fromJson(jsonDecode(response.body));
        getAllVegMenuItemsMap(jsonDecode(response.body)['menuItems']);
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: 'Unable to load all Items');
    }
    running = false;
  }

  static void getAllVegMenuItemsMap(var data) {
    for (var restaurant in data) {
      String uid = restaurant['uid'];
      for (var category in restaurant['menuItemList']) {
        for (var subCategory in category['subCategory']) {
          for (var menuItem in subCategory['menuItems']) {
            if (menuItem['inStock'] && menuItem['label']=='Veg') {
              items.add(
                  '${menuItem['menuItemName'].toString().toLowerCase()};$uid');
            }
          }
        }
      }
    }
    print(items.length);
  }
  // static void getAllMenuItemsMap(MenuResponse menu) {
  //   log('inside getAllMenuItemMap');
  //   for (var item in menu.menuItems) {
  //     List<String> temp = [];
  //     for (var category in item.menuItemList) {
  //       for (var subCategory in category.subCategory) {
  //         for (var menuItem in subCategory.menuItems) {
  //           if (menuItem.inStock) {
  //             temp.add(menuItem.menuItemName);
  //           }
  //         }
  //       }
  //     }
  //     items[item.uid] = temp;
  //   }
  //   print(items);
  // }
}
