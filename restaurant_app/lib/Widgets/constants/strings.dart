// import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppStrings {
  //networking
  static const contentType = 'Content-Type';
  static const applicationJson = 'application/json; charset=UTF-8';
  // static const baseURL = "http://192.168.1.5:3000/api/";
  // static String baseURL = "${dotenv.env['BASE_URL']}";
  static String baseURL = "";
  static String loginEndpoint = "$baseURL/auth/login";
  static String updateRestaurantByIdEndpoint =
      "$baseURL/auth/updateRestaurantById";
  static String getRestaurantByIDEndpoint = "$baseURL/auth/getRestaurantUser";
  static String menuEndpoint = "$baseURL/menu/";
  static String saveMenuItemEndpoint = "${menuEndpoint}saveMenuItem";
  static String getMenuItemEndpoint = "${menuEndpoint}getMenuItem";
  static String updateMenuItemEndpoint = "${menuEndpoint}updateMenuItem";
  static String deleteMenuItemEndpoint = "${menuEndpoint}deleteMenuItem";
  static String getCategorymenu = '$baseURL/menu/fetchAllCategories';
  static String getrestauarntbyid ='$baseURL/auth/getRestaurantUser';

  //categories api
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";
  // static String deleteMenuItemEndpoint = "${menuEndpoint}/deleteMenuItem";

  //delivery boy api
  static String getAllDeliveryBoysEndpoint = "$baseURL/auth/getAllDeliveryBoys";

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

  //shared preferences
  static const userId = "User_id";
  static const userInfo = "userInfo";
  static const timeToPrepare = "timeToPrepare";
  static const restaurantModel = "restaurantModel";
  static const mobilenumber = "contact_number";

  //menu screen
  static const noItemsFound = "No Items Found";
  static const failedToLoadMenuItems = "Failed to load menu items.";
  static const List<String> subCategory = [
    'Veg',
    'Non-Veg',
    'Vegan',
    'Gluten-Free',
    'Dairy Free',
  ];

  //registration screen
  static const List<String> cuisinesList = [
    "Chinese",
    "Momos",
    "Mughlai",
    "Mexican",
    "Arabic",
    "Bihari",
    "North Indian",
    "Thai",
    "South Indian",
    "Chaat",
    "Italian",
    "Cakes",
    "Bakery",
    "Sweets",
    "Himachali",
    "Bengali",
    "Nepali",
    "Continental",
    "Hyderabadi",
    "Gujrati",
    "Maharastrian"
  ];

  static List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  //Orders apis
  static String orderEndpoint = "$baseURL/order/";
  static String getAllOrdersEndpoint = "${orderEndpoint}getAllOrders";
  static String getOrderByIDEndpoint = "${orderEndpoint}orders";
  static String updateOrderEndpoint = "${orderEndpoint}orders";
  static String deleteOrderEndpoint = "${orderEndpoint}orders";
  //errors
  static const failedToLoadOrderItems = "Failed to load order items.";
  static const failedToLoadOrderItem = "Failed to load order item.";
  static const failedToUpdateOrderItem = "Failed to update order item.";
  static const failedToDeleteOrderItem = "Failed to delete order item.";
  static const noOrdersFound = "No orders found";
}
