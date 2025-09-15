import 'package:flutter/material.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';


class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  bool _isChecked = false; // State variable to manage checkbox state
  TextEditingController cardNumber = TextEditingController();
  TextEditingController validDate = TextEditingController();
  TextEditingController cvv = TextEditingController();
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures content resizes when the keyboard appears
      body: SingleChildScrollView( // Makes the content scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      'Add new Card',
                      style: h4TextStyle
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('ENTER CARD NO.', 'XXXX XXXX 1234',cardNumber),
              const SizedBox(height: 30),
              _buildTextField('VALID TILL', 'ENTER THE DATE',validDate),
              const SizedBox(height: 30),
              TextField(
                controller: cvv,
                obscureText: true,  // This will show *** for the input
                obscuringCharacter: '*',
                // maxLength: 3,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20),
                  hintText: 'ENTER YOU CVV',
                  labelText: 'CVV',
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
              const SizedBox(height: 30),
              _buildTextField('NAME ON CARD', 'ENTER THE NAME',name),
              const SizedBox(height: 5),
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
                  width: MediaQuery.of(context).size.width * 0.9,
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
                          fontWeight: FontWeight.bold),
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

  Widget _buildTextField(String labelText, String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        hintText: hintText,
        labelText: labelText,
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
    );
  }
}