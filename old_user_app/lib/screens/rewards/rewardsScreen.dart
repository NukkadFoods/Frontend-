import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isdarkmode ? textGrey2 : Colors.black,
        ), // Replace with your desired icon
        onPressed: () {
          Navigator.of(context).pop();
        },
      )),
      body: Stack(children: [
        Image.asset('assets/images/background.png'),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Foodie Rewards',
                  style: h3TextStyle,
                ),
                const SizedBox(
                  height: 50,
                ),
                SvgPicture.asset(
                  'assets/icons/day${context.read<GlobalProvider>().streak%7}.svg',
                  colorFilter: context.read<GlobalProvider>().streak == 0
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcATop)
                      : null,
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF17A1FA),
                        Color(0xFF9747FF)
                      ], // Replace with your desired colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      // Image on the left
                      Container(
                        padding: const EdgeInsets.only(left: 30),
                        width: 80, // Set the width of the image container
                        height: 80, // Set the height of the image container
                        child: Image.asset('assets/images/fire.png'),
                      ),
                      const SizedBox(
                          width: 8.0), // Space between image and column
                      // Column with two text widgets on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Day ${context.read<GlobalProvider>().streak} of daily streak!',
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: isdarkmode
                                    ? textBlack
                                    : Colors
                                        .white, // Make text white to stand out on gradient background
                              ),
                            ),
                            const SizedBox(
                                height:
                                    8.0), // Space between the two text widgets
                            Text(
                              '${6 - context.read<GlobalProvider>().streak} More days to go....',
                              style: const TextStyle(
                                  fontSize: 18.0,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Order daily for 6 days to complete streaks, after 6th order delivery, you earn ₹ ${context.read<GlobalProvider>().constants['foodieReward']} in nukkad walllet which can be used to order food or buy premium',
                    textAlign: TextAlign.center,
                    style: body5TextStyle.copyWith(
                        color: isdarkmode ? textGrey2 : textBlack),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      // Image on the left
                      SizedBox(
                        width: 80, // Set the width of the image container
                        height: 80, // Set the height of the image container
                        child: Image.asset('assets/images/wallet_2.png'),
                      ),
                      const SizedBox(
                          width: 8.0), // Space between image and column
                      // Column with two text widgets on the right
                      Expanded(
                        child: Text(
                          '₹ ${context.read<GlobalProvider>().constants['foodieReward']} Wallet Cash',
                          style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'terms and conditions',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
