import 'package:driver_app/screens/other_screens/nukkad_manager_screen.dart';
import 'package:driver_app/screens/support_screens/complaint_screen.dart';
import 'package:driver_app/screens/support_screens/help_center_screen.dart';
import 'package:driver_app/screens/support_screens/payouts_page.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/widgets/home/menu_item.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: colorGray)),
      width: double.infinity,
      margin: EdgeInsets.only(top: 10), // Adjust margin as needed
      padding: EdgeInsets.all(10),
      child: const Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              'Accessibility',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuItem(
                iconPath: 'assets/svgs/complaints.svg',
                label: 'Complaints',
                screen: ComplaintScreen(),
              ),
              MenuItem(
                iconPath: 'assets/svgs/help.svg',
                label: 'Help Centre',
                screen: HelpCentreScreen(),
              ),
              MenuItem(
                iconPath: 'assets/svgs/manager.svg',
                label: 'Your\nmanager',
                screen: NukkadManagerScreen(),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuItem(
                  iconPath: 'assets/svgs/payout.svg',
                  label: 'Payouts',
                  screen: PayoutsPage()),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
