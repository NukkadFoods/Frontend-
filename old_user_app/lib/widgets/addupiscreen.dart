import 'package:flutter/material.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class AddUpiIdScreen extends StatefulWidget {
  const AddUpiIdScreen({super.key});

  @override
  _AddUpiIdScreenState createState() => _AddUpiIdScreenState();
}

class _AddUpiIdScreenState extends State<AddUpiIdScreen> {
  bool _isChecked = false; // State variable to manage checkbox state
  TextEditingController upiID = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons/arrow_back.png',
                        color: textBlack,
                        height: 20,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.17),
                    Text(
                      'Add new UPI id',
                      style: h4TextStyle
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              TextField(
                controller: upiID,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  hintText: 'Abcdefg@okaxisbank',
                  labelText: 'ENTER YOUR UPI ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey), // Grey border when unfocused
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2.0), // Grey border when focused
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Row(
                children: [
                  // The Checkbox is now using the _isChecked state to manage its value
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      // Update the checkbox state when it's clicked
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Text('Save this id for future use'),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your verification and payment logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Background color
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'VERIFY AND PAY',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}