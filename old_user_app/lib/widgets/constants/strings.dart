import 'dart:math';


class AppStrings {
  AppStrings._();
  //networking
  static const contentType = 'Content-Type';
  static const applicationJson = 'application/json; charset=UTF-8';
  // static const baseURL = "http://192.168.1.5:3000/api/";
  // static String baseURL = "${dotenv.env['BASE_URL']}";
  static String baseURL = "";
  static String menuEndpoint = "$baseURL/menu/";
  static String saveMenuItemEndpoint = "${menuEndpoint}saveMenuItem";
  static String getMenuItemEndpoint = "${menuEndpoint}getMenuItem";
  static String updateMenuItemEndpoint = "${menuEndpoint}updateMenuItem";
  static String deleteMenuItemEndpoint = "${menuEndpoint}deleteMenuItem";
  static String GOOGLE_API_KEY = "AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw";

  //categories api
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";

  //errors
  static const loginError = 'Login failed';
  static const menuLoadError = "Menu items not found";
  static const serverError = "Server error. Please try again later.";
  static const other = "Other";
  static const failedToUpdateMenuItem = "Failed to update menu item.";
  static const failedToDeleteMenuItem = "Failed to delete menu item.";
  static const allFieldsRequired = "All Fields are required";
  static const failedToFetchCategories = "Failed to fetch categories";
  static const failedToAddSubCategory = "Failed to Add Sub categories";

  //menu screen
  static const noItemsFound = "No Items Found";
  static const noCategoriesFound = "No Categories Found";
  static const failedToLoadMenuItems = "Failed to load menu items.";

  //shared preferences
  static const userId = "User_id";
  static const String cartItemCountKey = 'cartItemCount';
  static const String cartItemTotalKey = 'cartItemTotal';
  static const String userNameKey = 'user_name';
  static const String ownerImageUrl = 'ownerImageUrl';
  static const String mobilenumber = 'mobilenumber';
  static const String cart = 'cart';

  //Orders apis
  static String orderEndpoint = "$baseURL/order/";
  static String getAllOrdersEndpoint = "${orderEndpoint}orders";
  static String getOrderByIDEndpoint = "${orderEndpoint}orders";
  static String updateOrderEndpoint = "${orderEndpoint}orders";
  static String deleteOrderEndpoint = "${orderEndpoint}orders";
  static String createOrderEndpoint = "${orderEndpoint}createOrder";

  //errors
  static const failedToLoadOrderItems = "Failed to load order items.";
  static const failedToLoadOrderItem = "Failed to load order item.";
  static const failedToUpdateOrderItem = "Failed to update order item.";
  static const failedToDeleteOrderItem = "Failed to delete order item.";
  static const noOrdersFound = "No orders found";
  static const internalServerError = 'Internal server error';
  static const unexpectedError = 'Unexpected error';
  static const failedToCreateOrderItem = 'Failed to create order item';

  //food apis
  static String fetchAllRestaurantsEndpoint =
      "$baseURL/auth/fetchAllRestaurants";

  //cart apis
  static String addToCartEndpoint = "$baseURL/auth/addtocart";
  static String removeFromCartEndpoint = "$baseURL/auth/removefromcart";

  //favorite apis
  static String addToFavoriteEndpoint = "$baseURL/auth/addFavorite";
  static String removeFromFavoriteEndpoint = "$baseURL/auth/removeFavorite";

  //hidden api
  static String addToHiddenEndpoint = "$baseURL/auth/addHidden";
  static String removeFromHiddenEndpoint = "$baseURL/auth/removeHidden";

  //errors
  static const failedToLoadRestaurants = "Failed to load restaurants.";
  static const noRestaurantsFound =
      "No restaurant found Sorry.. We will Soon be here....";

  //lable of menu
  static const List<String> lable = [
    'Veg',
    'Non-Veg',
    'Vegan',
    'Gluten-Free',
    'Dairy Free',
  ];
  static const List<String> lableIcons = [
    'assets/icons/veg_icon.png',
    'assets/icons/non_veg_icon.png',
    'assets/icons/vegan_icon.png',
    'assets/icons/gluten_free_icon.png',
    'assets/icons/dairy_free_icon.png',
  ];

  //user
  static String userEndpoint = "$baseURL/auth/getUserByID";
  static String updateUserEndpoint = "$baseURL/auth/updateUserById";
  static const failedToLoadUserInfo = "Failed to load user information";
  static const noUserFound = "No user found";
  static String generateUniqueId() {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String randomString =
        List.generate(5, (index) => Random().nextInt(10)).join();
    return '$timestamp-$randomString';
  }
}
