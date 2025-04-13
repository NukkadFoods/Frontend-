// import 'package:flutter/material.dart';

// import '../../utils/font-styles.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/common/full_width_green_button.dart';
// import '../../widgets/common/transition_to_next_screen.dart';
// import '../home_screens/home_screen.dart';

// class AddAddressScreen extends StatefulWidget {
//   const AddAddressScreen({super.key});

//   @override
//   State<AddAddressScreen> createState() => _AddAddressScreenState();
// }

// class _AddAddressScreenState extends State<AddAddressScreen> {
//   TextEditingController _houseNumberController = TextEditingController();
//   TextEditingController _apartementController = TextEditingController();
//   TextEditingController _colonyController = TextEditingController();
//   TextEditingController _howToReachController = TextEditingController();
//   TextEditingController _saveAsController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         leading: GestureDetector(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             child: Icon(Icons.arrow_back_ios_new)),
//         title: Row(
//           children: [
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.18,
//             ),
//             Text(
//               'Add Address',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: mediumLarge,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             SizedBox(
//               height: 40,
//             ),
//             CustomTextField(
//               label: 'HOUSE FLAT NO.',
//               controller: _houseNumberController,
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             CustomTextField(
//               label: 'APARTMENT/ROAD/AREA',
//               controller: _apartementController,
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             CustomTextField(
//               label: 'COLONY (OPTIONAL)',
//               controller: _colonyController,
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             CustomTextField(
//               label: 'HOW TO REACH',
//               controller: _howToReachController,
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             CustomTextField(
//               label: 'SAVE AS',
//               controller: _saveAsController,
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             FullWidthGreenButton(
//                 label: 'SAVE ADDRESS',
//                 onPressed: () {
//                   Navigator.of(context)
//                       .push(transitionToNextScreen(HomeScreen()));
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
