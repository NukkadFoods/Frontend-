import 'package:driver_app/controller/wallet_controller.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final updates = WalletController.wallet!.updates!.reversed.toList();
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Wallet History",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_new))),
      body: updates.isEmpty
          ? const Center(
              child: Text("No History To Show"),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
