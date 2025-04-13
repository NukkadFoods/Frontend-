import 'package:flutter/material.dart';

import '../Widgets/constants/colors.dart';
import '../Widgets/constants/texts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'Order Confirmation',
      'body': 'Your order #12345 has been confirmed.',
      'time': '2 mins ago'
    },
    {
      'title': 'New Message',
      'body': 'You have a new message from John.',
      'time': '5 mins ago'
    },
    {
      'title': 'Promotion',
      'body': 'Get 20% off on your next order!',
      'time': '10 mins ago'
    },
    {
      'title': 'Delivery Update',
      'body': 'Your order is out for delivery.',
      'time': '15 mins ago'
    },
    {'title': 'Welcome', 'body': 'Welcome to our app!', 'time': '20 mins ago'},
    {
      'title': 'Reminder',
      'body': 'Don\'t forget to complete your profile.',
      'time': '25 mins ago'
    },
    {
      'title': 'Review Request',
      'body': 'Please review your recent purchase.',
      'time': '30 mins ago'
    },
    {
      'title': 'Referral',
      'body': 'Refer a friend and earn rewards.',
      'time': '35 mins ago'
    },
    {
      'title': 'Feedback',
      'body': 'We would love to hear your feedback.',
      'time': '40 mins ago'
    },
    {
      'title': 'Weekly Update',
      'body': 'Here\'s what\'s new this week.',
      'time': '45 mins ago'
    },
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
        title: Text('Notifications', style: h4TextStyle),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification['title']!, style: h5TextStyle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['body']!, style: body4TextStyle),
                Text(notification['time']!, style: body4TextStyle),
              ],
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
