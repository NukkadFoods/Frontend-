import 'package:driver_app/utils/font-styles.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen(
      {super.key, required this.cities, this.selectedCity});
  final String? selectedCity;
  final List<String> cities;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select City"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: cities.isEmpty
          ? Center(
              child: Text(
                'Error In Loading Cities',
                style: TextStyle(fontSize: medium),
              ),
            )
          : ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    cities[index],
                    style: TextStyle(fontSize: medium),
                  ),
                  onTap: () {
                    Navigator.pop(context, cities[index]);
                  },
                  trailing:
                      selectedCity == cities[index] ? Icon(Icons.check) : null,
                );
              },
            ),
    );
  }
}
