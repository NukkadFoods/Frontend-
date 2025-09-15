import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:user_app/Widgets/constants/colors.dart';
import 'package:user_app/Widgets/constants/texts.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final List<Widget> planWidgets = [
    const PlanWidget(planName: 'Standard'),
    const PlanWidget(planName: 'Corporate'),
    const PlanWidget(planName: 'Foodie'),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: textBlack),
        ),
        title: Text('Your Subscriptions', style: h4TextStyle),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          height: 60.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: planWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You clicked at $index"),
                    ),
                  );
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: planWidgets[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PlanWidget extends StatelessWidget {
  final String planName;

  const PlanWidget({super.key, required this.planName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4399F9),
            Color(0xFF8353FC),
            Color(0xFF9D3BFD),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          planName,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
