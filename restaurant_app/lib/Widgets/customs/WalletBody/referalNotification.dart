import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart'; // Import Lottie for animation
import 'package:sizer/sizer.dart';  // Optional: For responsive sizing

class ReferCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.fromLTRB(4.w, 1.w, 1.w, 0.w),  // Adjust spacing based on screen size
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 66, 136, 249), Color.fromARGB(255, 218, 226, 241)], // Light blue gradient background
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Left side text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refer And Earn!",
                  style: TextStyle(
                    fontSize: 16.sp,  // Font size according to screen size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h), // Spacing between title and description
                Text(
                  "Refer a friend to Nukkad \nfoods and you both earn ₹50\n when they place their first order!",
                  style: TextStyle(
                    fontSize: 8.sp,  // Font size according to screen size
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),  // Spacing between description and button
                ElevatedButton(
                  onPressed: () {
                    // Action for refer button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    foregroundColor: Color(0xFF5A82E0), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric( vertical: 1.h),  // Button padding
                    child: Text(
                      "Refer now",
                      style: TextStyle(
                        fontSize: 8.sp,  // Font size according to screen size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w), // Space between text and image

          // Right side image and Lottie animation
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Speakerman image
              Image.asset(
                'assets/images/speaker.png',  // Your image path
                width: 35.w,
                height: 20.h,
                
              ),
              // Lottie box animation
              Positioned(
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: 16.w,
                  child: Lottie.asset(
                    'assets/animations/box.json', // Your Lottie animation path
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
