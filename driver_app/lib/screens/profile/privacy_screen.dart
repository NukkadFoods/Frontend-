import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
          centerTitle: true,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            data,
            style: TextStyle(fontSize: 16),
          ),
        ))));
  }

  String data = '''
Nukkadfoods operates a food delivery platform through our app, onboarding street food vendors and delivery personnel. Our privacy policy aims to create transparency regarding how we collect, use, and protect your data, and with whom we share it for necessary tasks.


Information Collection


1. Personal Information:

   - From users: name, email, phone number, address, and location.

   - From street food vendors: GST number, FSSAI license, owner details, restaurant details (address, location, image).

   - From delivery personnel: photo, vehicle details, personal details, and vehicle license.


2. Order Information:

   - Details such as delivery instructions, payment type, location, additional instructions, cutlery requirements, preparation time, and delivery time.


3. Usage Data:

   - Location access, camera access for photos during sign-up, and device vibration for user experience enhancements.


4. Cookies and Tracking Technologies:

   - Saved data to provide easier access upon the user's return.


How Information is Used


1. Service Delivery:

   - Information is used to process orders, deliver food, and communicate with users. Data is stored in MongoDB and transferred to the admin portal to manage data flow.


2. Customer Support:

   - Used to identify and resolve issues related to orders.


3. Marketing and Promotions:

   - Overall data such as sales numbers is used for public and partner communications. User consent is obtained for these activities.


4. Analytics:

   - Data is used to analyze app usage and improve user experience.


Information Sharing and Disclosure


1. Third-Party Service Providers:

   - Personal information is not shared with third-party apps.


2. Legal Requirements:

   - Information may be disclosed in response to legal obligations, court orders, or other legal processes.


3. Business Transfers:

   - In the event of mergers, acquisitions, or other business transactions, information will be transferred to the merging party or new entity.


Data Security


1. Measures Taken:

   - Uses Cloudflare, Google, and MongoDB’s self-protection features to safeguard personal information.


2. User Protection:

   - Users are encouraged to use strong passwords and enable two-factor authentication.


User Rights and Choices


1. Access and Correction:

   - Users can access, update, or correct their personal information through an edit facility in the app, with verification if necessary.


2. Opt-Out:

   - Users can opt out of marketing communications by unsubscribing from emails, opting out of WhatsApp messages, or disabling notifications in the app settings.


3. Data Deletion:

   - Users can request deletion of their personal information by contacting support.


Children’s Privacy


- Nukkadfoods does not collect data from children under a certain age, and parental consent requirements are not applicable.


Changes to the Privacy Policy


- Users will be notified of changes to the privacy policy via email at least 30 days before the changes take effect.

- The effective date of the current privacy policy will be provided in the policy document.


Contact Information


- Users can contact Nukkadfoods with questions or concerns about the privacy policy or their personal information via support channels or email.




''';
}
