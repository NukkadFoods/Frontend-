// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class PizzaWidget extends StatelessWidget {
//   final String pizzaSlicePath = 'assets/images/pizzaslice.svg'; // Path to the SVG image of pizza slice
//   final int sliceCount; // Number of slices to turn red

//   const PizzaWidget({super.key, required this.sliceCount}); // Constructor to pass the slice count

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
       
//           children: List.generate(8, (index) {
//             Color sliceColor;

//             // Determine the color of the slice based on sliceCount
//             if (sliceCount == 7) {
//               sliceColor = Colors.yellow; // All slices turn yellow
//             } else if (index < sliceCount) {
//               sliceColor = Colors.red; // First 'sliceCount' slices turn red
//             } else {
//               sliceColor = Colors.transparent; // Remaining slices stay uncolored
//             }

//             return Transform.rotate(
//               angle: (index * 45) * (3.14159 / 180), // Rotate each slice by 45 degrees
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     pizzaSlicePath,
//                     width: 150,
//                     height: 150,
//                     color: sliceColor.withOpacity(0.8), // Color the slice with opacity
//                   ),
//                 ],
//               ),
//             );
//           }),
    
//     );
//   }
// }
