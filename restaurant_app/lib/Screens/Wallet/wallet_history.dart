import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:restaurant_app/Controller/wallet_controller.dart';
import 'package:restaurant_app/Screens/Wallet/viewEarningsScreen.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = WalletController.wallet!.updates!.reversed.toList();
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Wallet History",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new))),
      body: updates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/noRecords.png',
                    width: MediaQuery.sizeOf(context).width * .8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text("No Records found"),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: updates.length,
              itemBuilder: (context, index) => Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: ListTile(
                  minTileHeight: 0,
                  title: Text(updates[index].status!.capitalize()),
                  subtitle: Text(
                    updates[index].date!.split('T')[0],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text(
                    updates[index].amount!.toStringAsFixed(2),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: updates[index].amount!.isNegative
                            ? Colors.red
                            : Colors.green),
                  ),
                ),
              ),
            ),
    );
  }
}
