import 'package:flutter/material.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black, // Black background color
        borderRadius:
            BorderRadius.circular(8.0), // Adjust border radius as needed
      ),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close,
              color: Colors.white, // White icon color
            ),
            const SizedBox(height: 4), // Add some space between icon and text
            Text(
              'Cancel',
              style: TextStyle(color: Colors.white), // White text color
            ),
          ],
        ),
      ),
    );
  }
}
