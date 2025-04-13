import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MenuItemsPage extends StatefulWidget {
  const MenuItemsPage({super.key});

  @override
  _MenuItemsPageState createState() => _MenuItemsPageState();
}

class _MenuItemsPageState extends State<MenuItemsPage> {
  List<Map<String, dynamic>> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  // Function to fetch the menu items from API
  Future<void> fetchMenuItems() async {
    final url = Uri.parse('https://nukkad-foods-backend-vercel.vercel.app/api/fetchAllitems'); // Enter your API URL here
    try {
      final response = await http.get(url);
        print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final existingMenuItems = data['existingMenuItems'][0]['menuItemList'];

        // Extract the menu items and add to _menuItems list
        List<Map<String, dynamic>> items = [];
        for (var category in existingMenuItems) {
          for (var subCategory in category['subCategory']) {
            for (var menuItem in subCategory['menuItems']) {
              if (menuItem['isAvailable']) {
                items.add({
                  'name': menuItem['name'],
                  'price': menuItem['price'],
                });
              }
            }
          }
        }

        setState(() {
          _menuItems = items;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load menu items');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Items'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_menuItems[index]['name']),
                  subtitle: Text('Price: \$${_menuItems[index]['price']}'),
                );
              },
            ),
    );
  }
}
