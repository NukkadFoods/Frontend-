import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:user_app/providers/global_provider.dart';
import 'package:user_app/screens/Subscriptions/subscription_payment.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';
import 'package:user_app/widgets/customs/pagetransition.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  _SubscriptionPlanScreenState createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String selectedPlan = ''; // Variable to store the selected plan
  late Map cost;
  late List benefits;

  @override
  void initState() {
    super.initState();
    cost = context.read<GlobalProvider>().constants['subsCost'];
    benefits = context.read<GlobalProvider>().constants['premiumBenefits'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Subscription',
            style: h4TextStyle.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? textWhite
                    : textBlack)),
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? textBlack
            : textWhite,
      ),
      body: Stack(
        children: [
          // Ensure your background image is added in the assets
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // Your background image
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // If the image fails to load, fallback to a plain color
                return Container(color: Colors.grey);
              },
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Lottie.asset(
                      'assets/animations/subscription.json', // Lottie animation
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback in case Lottie fails to load
                        return Container(
                          height: 200,
                          color: Colors.grey,
                          child: const Center(
                              child: Text('Animation failed to load')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      Text(
                        ' BENEFITS ',
                        style: h4TextStyle.copyWith(
                          letterSpacing: 1.7,
                          color: primaryColor,
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  for (int i = 0; i < benefits.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star_border_rounded,
                              color: Colors.amberAccent),
                          Flexible(
                            child: Text(
                              benefits[i],
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Choose the right plan for you!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPlanSelectionContainer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelectionContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: textGrey1, width: 1),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : textWhite,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'SELECT YOUR PLAN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? textWhite
                  : textBlack,
            ),
          ),
          const SizedBox(height: 10),
          _buildPlanOption(
              'WEEKLY',
              '₹${cost['weekly']['price']}',
              '/ week (only ${cost['weekly']['price']}/week)',
              '${cost['weekly']['walletPercentage']}% Wallet cash'),
          const SizedBox(height: 10),
          _buildPlanOption(
              'MONTHLY',
              '₹${cost['monthly']['price']}',
              '/ month (no free trial)',
              '${cost['monthly']['walletPercentage']}% Wallet cash'),
          const SizedBox(height: 10),
          _buildPlanOption(
              '3-MONTH',
              '₹${cost['3-month']['price']}',
              '/ 3-month (no free trial)',
              '${cost['3-month']['walletPercentage']}% Wallet cash'),
          const SizedBox(height: 20),
          // Button to subscribe
          Center(
            child: mainButton('Continue', textWhite, () {
              print(selectedPlan);
              if (selectedPlan == "WEEKLY") {
                Navigator.of(context)
                    .push(transitionToNextScreen(SubscriptionCheckout(
                  amount: cost['weekly']['price'].toDouble(),
                  fractionWalletUsed: cost['weekly']['walletPercentage'] / 100,
                  plan: "WEEKLY",
                )));
              } else if (selectedPlan == "MONTHLY") {
                Navigator.of(context)
                    .push(transitionToNextScreen(SubscriptionCheckout(
                  amount: cost['monthly']['price'].toDouble(),
                  fractionWalletUsed: cost['monthly']['walletPercentage'] / 100,
                  plan: "MONTHLY",
                )));
              } else if (selectedPlan == "3-MONTH") {
                Navigator.of(context)
                    .push(transitionToNextScreen(SubscriptionCheckout(
                  amount: cost['3-month']['price'].toDouble(),
                  fractionWalletUsed: cost['3-month']['walletPercentage'] / 100,
                  plan: "3-MONTH",
                )));
              }
            }),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No thanks',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
      String plan, String price, String description, String offer) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print(plan);
          selectedPlan = plan;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? textBlack
              : textWhite,
          border: Border.all(
            color: selectedPlan == plan ? Colors.blue : Colors.grey,
            width: selectedPlan == plan ? 4 : 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan),
              _buildOfferBadge(offer),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                price,
                style: h5TextStyle.copyWith(
                    color: const Color.fromARGB(228, 250, 192, 0)),
              ),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferBadge(String offer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5AE6FD),
            Color(0xFF9C40E7)
          ], // Gradient colors from blue to purple
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        offer,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
