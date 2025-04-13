import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/Widgets/constants/strings.dart'; // Add this import

// final String baseUrl = dotenv.env['BASE_URL']!;
final String baseUrl = AppStrings.baseURL;
// Future<void> loadEnv() async {
//     await dotenv.load(fileName: ".env");
// }

class MenuApi {
  // static const String baseUrl = 'https://your-backend-url.com/api/menu';

  // Fetch all categories for a restaurant
  static Future<List<String>> fetchAllCategories(String uid) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fetchAllCategories'),
      body: jsonEncode({'uid': uid}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<String> categories = List<String>.from(responseBody['categories']);
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Add a new category to a restaurant's menu
  static Future<void> addCategory(String uid, String category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addcategory'),
      body: jsonEncode({'uid': uid, 'category': category}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }

  // Delete a category from a restaurant's menu
  static Future<void> deleteCategory(String uid, String category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteCategory'),
      body: jsonEncode({'uid': uid, 'category': category}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  // Fetch all subcategories for a given category in a restaurant's menu
  static Future<List<String>> fetchAllSubCategories(String uid, String category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fetchAllSubCategories'),
      body: jsonEncode({'uid': uid, 'category': category}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      List<String> subCategories = List<String>.from(responseBody['subCategories']);
      return subCategories;
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  // Add a new subcategory to a category in a restaurant's menu
  static Future<void> addSubCategory(String uid, String category, String subCategory) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addSubCategory'),
      body: jsonEncode({'uid': uid, 'category': category, 'subCategory': subCategory}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add subcategory');
    }
  }

  // Delete a subcategory from a category in a restaurant's menu
  static Future<void> deleteSubCategory(String uid, String category, String subCategory) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteSubCategory'),
      body: jsonEncode({'uid': uid, 'category': category, 'subCategory': subCategory}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete subcategory');
    }
  }


  // Other functions like saveMenuItem, getMenuItem, updateMenuItem, etc. can be added similarly

  // Save a new menu item
  static Future<void> saveMenuItem(String uid, String category, String subCategory, Map<String, dynamic> menuItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saveMenuItem'),
      body: jsonEncode({
        'uid': uid,
        'category': category,
        'subCategory': subCategory,
        'menuItem': menuItem,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save menu item');
    }
  }

  // Get menu items
  static Future<List<Map<String, dynamic>>> getMenuItems(String uid, {required String category,  required String subCategory}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/getMenuItem/$uid'),
      body: jsonEncode({
        'category': category,
        'subCategory': subCategory,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  // Update an existing menu item
  static Future<void> updateMenuItem(String uid, String category, String subCategory, String menuItemId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateMenuItem/$uid/$category/$subCategory/$menuItemId'),
      body: jsonEncode({'updatedata': updatedData}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update menu item');
    }
  }

  // Delete a menu item
  static Future<void> deleteMenuItem(String uid, String category, String subCategory, String menuItemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deleteMenuItem/$uid/$category/$subCategory/$menuItemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item');
    }
  }


}

