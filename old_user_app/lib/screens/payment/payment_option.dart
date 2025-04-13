import 'package:flutter/material.dart';
import 'package:user_app/Controller/payment/type_of_payment.dart';
import 'package:user_app/widgets/buttons/mainButton.dart';
import 'package:user_app/widgets/constants/colors.dart';
import 'package:user_app/widgets/constants/texts.dart';

class PaymentOptionsScreen extends StatefulWidget {
  const PaymentOptionsScreen({
    super.key,
    required this.restuarantname,
    required this.totalprice,
  });

  final String restuarantname;
  final double totalprice;

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  final PaymentTypeController paymentTypeController = PaymentTypeController();

  @override
  Widget build(BuildContext context) {
     bool isdarkmode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
          
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Payment options', style: h4TextStyle.copyWith(color: isdarkmode ? textGrey2: textBlack)),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: textGrey1),
                
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From ${widget.restuarantname}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold,color: isdarkmode ? textGrey2: textBlack),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Delivery in 25 Mins',
                        style: TextStyle(color: primaryColor),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: textGrey1,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '₹ ${widget.totalprice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            Material(
             
              borderRadius: BorderRadius.circular(10),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: textBlack),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildPaymentOption(
                  'Cash On Delivery',
                  1,
                  'assets/images/dollar.png',
                  isdarkmode
                ),
              ),
            ),
            const SizedBox(height: 10),
            Material(
             
              borderRadius: BorderRadius.circular(10),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: textBlack),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildPaymentOption(
                  'Pay Online',
                  2,
                  'assets/images/googlePay.png',
                  isdarkmode
                ),
              ),
            ),
            const SizedBox(height: 20),
            mainButton('Continue',isdarkmode? textBlack: textWhite, route),
          ],
        ),
      ),
    );
  }

  void route() {
    // Navigate or perform actions with the selected payment method
    Navigator.pop(context);
  }

  Widget _buildPaymentOption(String title, int value, String imagePath,bool isdarkmode) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(imagePath),
      ),
      title: Text(title, style: TextStyle(color: isdarkmode ? textGrey2: textBlack),),
      trailing: ValueListenableBuilder<int>(
        valueListenable: paymentTypeController.selectedPaymentMethod,
        builder: (context, selectedValue, _) {
          return Radio(
            value: value,
            groupValue: selectedValue,
            activeColor: primaryColor,
            onChanged: (value) {
              paymentTypeController.setPaymentMethod(value as int);
            },
          );
        },
      ),
    );
  }
}
