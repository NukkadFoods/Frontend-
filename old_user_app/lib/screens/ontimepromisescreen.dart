import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';  // For the SVG icon
class OnTimePromisePage extends StatefulWidget {
  const OnTimePromisePage({super.key});

  @override
  _OnTimePromisePageState createState() => _OnTimePromisePageState();
}

class _OnTimePromisePageState extends State<OnTimePromisePage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
     TextStyle theme=isdarkmode ?h5TextStyle.copyWith(color:textGrey2): h5TextStyle;
     TextStyle  h2TextStyletheme =isdarkmode ? h2TextStyle.copyWith(color: textGrey2) : h2TextStyle;
     TextStyle  body5TextStyletheme= isdarkmode ? body5TextStyle.copyWith(color: textGrey2) : body5TextStyle;
    return Scaffold(
    
      body: SingleChildScrollView(
        controller: _scrollController,
       
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
  height: 300,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color.fromARGB(222, 234, 209, 172),
       isdarkmode ? Colors.transparent : Colors.white,
      ],
    ),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Image.asset('assets/images/scooterpromise.png', height: 200,width: double.maxFinite,),
           ],
            ),
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: textGrey1),
                  borderRadius: BorderRadius.circular(10)
                ),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 const SizedBox(height: 16.0),
                Text(
                  'Our Promise',
                  style: h2TextStyletheme,
                ),
                const SizedBox(height: 26.0),
                Text(
                  '1. On-Time Promise',
                  style:  theme,
                ),
                  const SizedBox(height: 16.0),
                Text(
                  'Briefly introduces the concept of the on-time promise, emphasizing the app’s dedication to customer satisfaction through timely deliveries.',
                  style: body5TextStyletheme
                ),
                const SizedBox(height: 26.0),
                Text(
                  '2. Our Purpose',
                  style: theme
                ),
                const  SizedBox(height: 16.0),
                Text(
                  'To provide quick overview and capture the user\'s attention with the promise of reliable service.',
                  style: body5TextStyletheme
                ),
                  const  SizedBox(height: 26.0),
                Text(
                  '3. How It Works',
                  style: theme
                ),
                   const  SizedBox(height: 16.0),
                Text(
                  '. Order Placement: Steps for placing an order and choosing the on-time promise option if available.\n'
                  '  \n'
                  '. Estimated Delivery Time: How the app calculates and displays the estimated delivery time for the order.\n'
                    '  \n'
                  '. Purpose: To inform users of the process and reassure them of the reliability of the promised delivery times.',
                  style: body5TextStyletheme
                ),
                  const  SizedBox(height: 26.0),
                Text(
                  '4. Eligibility Criteria',
                  style:theme
                ),
                   const  SizedBox(height: 16.0),
                Text(
                  'Geographic areas: Specific regions or locations where the promise is valid.',
                  style: body5TextStyletheme
                ),
              const  SizedBox(height: 26.0),
                Text(
                  '5. Benefits',
                  style: theme
                ),
                   const  SizedBox(height: 16.0),
                Text(
                  'Timely Delivery: Assurance of receiving food within the estimated time.\n'
                    '  \n'
                  'Compensation: Details of any compensation or benefits offered if the promise fails (e.g., discounts, credits, free items).',
                  style: body5TextStyletheme
                ),
              const  SizedBox(height: 26.0),
                Text(
                  '6. Customer Support',
                  style: theme),
                     const  SizedBox(height: 16.0),
                Text(
                  'Contact Methods: Options such as live chat, email, or phone support.\n'
                    '  \n'
                  'Reporting an Issue: Steps to report a late delivery and claim compensation if applicable.',
                  style: body5TextStyletheme
                ),
                  const  SizedBox(height: 26.0),// Add some space at the bottom for the floating button
                          ],
                        ),
              ),
            ),
            ],),
           
           
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: _scrollToTop,
        backgroundColor: primaryColor,
        child:  Icon(Icons.upload_rounded, color:isdarkmode ? textBlack : textWhite,)
      ),
    );
  }
}
