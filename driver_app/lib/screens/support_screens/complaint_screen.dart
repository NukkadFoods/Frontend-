import 'dart:convert';

import 'package:driver_app/controller/orders/orders_model.dart';
import 'package:driver_app/providers/complaints_provider.dart';
import 'package:driver_app/utils/colors.dart';
import 'package:driver_app/utils/font-styles.dart';
import 'package:driver_app/widgets/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../controller/toast.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ComplaintsProvider(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Complaints",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/otpbbg.png'),
                  fit: BoxFit.contain,
                  opacity: .5)),
          child: Column(
            children: [
              Consumer<ComplaintsProvider>(
                builder: (context, value, child) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < value.tabs.length; i++)
                        Tab(
                          label: value.tabs[i],
                          selected: value.selected,
                          index: i,
                          onPressed: () => value.changeSelected(i),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: Consumer<ComplaintsProvider>(
                builder: (context, value, child) => context
                        .read<ComplaintsProvider>()
                        .isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : context
                            .read<ComplaintsProvider>()
                            .filteredComplaints
                            .isEmpty
                        ? Center(
                            child: Text('No Complaints Found!'),
                          )
                        : ListView.builder(
                            itemCount: value.filteredComplaints.length,
                            //To be constructed from filteredComplaintsList
                            itemBuilder: (context, index) {
                              print(value.filteredComplaints[index]);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Complaint(
                                  provider: value,
                                  complaint: value.filteredComplaints[index],
                                ),
                              );
                            },
                          ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class Complaint extends StatefulWidget {
  const Complaint({
    super.key,
    required this.provider,
    required this.complaint,
  });
  final ComplaintsProvider provider;
  final Map<String, dynamic> complaint;
  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  bool isLoading = true;
  OrderData? orderData;
  late Map<String, dynamic> description;
  @override
  void initState() {
    super.initState();
    getData();
    description = jsonDecode(widget.complaint['description']);
  }

  void getData() async {
    if (widget.provider.loadedOrderData
        .containsKey(widget.complaint['orderID'])) {
      isLoading = false;
      orderData = widget.provider.loadedOrderData[widget.complaint['orderID']]!;
      if (mounted) {
        setState(() {});
      }
      return;
    } else {
      print('getting data');
      // String baseUrl = dotenv.env['BASE_URL']!;
      String baseUrl = AppStrings.baseURL;
      try {
        var response = await http.get(
            Uri.parse(
                '$baseUrl/order/orders/${widget.complaint['complaint_done_by_id']}/${widget.complaint['orderID']}'),
            headers: {"Content-Type": 'application/json'});
        if (response.statusCode == 200) {
          orderData = OrderData.fromJson(jsonDecode(response.body)['order']);
          widget.provider.loadedOrderData[orderData!.orderId!] = orderData!;
        } else {
          print(response.body);
        }
      } catch (e) {
        print(e);
        Toast.showToast(message: "Unable to load Order Data", isError: true);
      }
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> complaintsUpdate(Map complaint, String status) async {
    setState(() {
      isLoading = true;
    });
    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      String baseUrl = AppStrings.baseURL;
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // var userid = prefs.getString('uid');
      var reqData = {
        "status": status,
        "comment": "Issue $status",
        "commented_by": "Delivery"
      };
      String requestBody = jsonEncode(reqData);
      final response = await http.put(
          Uri.parse('$baseUrl/complaint/updateComplaint/${complaint['_id']}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: requestBody);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData != null) {
          Toast.showToast(message: "Complaints Resolve successfully");
          context.read<ComplaintsProvider>().getComplaints();
          setState(() {
            isLoading = false;
          });
          // print(widget.order);
        } else {
          setState(() {
            isLoading = false;
          });
          print(responseData['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.body);
        Toast.showToast(message: "Failed to Complaints Resolve", isError: true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : (orderData == null)
            ? Text('No Internet')
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorGray),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffff0000)),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7)),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: 'Order no. ${orderData!.orderId!}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: small,
                                        fontWeight: w600,
                                        height: 1.5)),
                                TextSpan(
                                    text: '\n${description['title']}',
                                    style: TextStyle(
                                        fontSize: medium,
                                        fontWeight: w600,
                                        color: Color(0xffff0000),
                                        height: 1.5))
                              ]),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorBrightGreen,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  ' ${widget.complaint['status']} ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            child:
                                Text(orderData!.orderByName![0].toUpperCase()),
                          ),
                          SizedBox(width: 10.0),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  orderData!.orderByName!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  orderData!.deliveryAddress!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(' ${orderData!.time!}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.0),
                    Divider(
                      indent: 15,
                      endIndent: 15,
                    ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            description['title']!,
                            style: TextStyle(
                                fontWeight: w600,
                                fontSize: 15,
                                color: colorBrightGreen),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: colorBrightGreen,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              ' Verified ',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                            color: Color(0xffffed47).withOpacity(.14),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: colorBrightGreen)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review: ',
                              style: TextStyle(
                                  fontSize: small,
                                  fontWeight: w600,
                                  color: colorBrightGreen),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                '“${description['description']}”',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.complaint['status'] != 'Resolved' &&
                        widget.complaint['status'] != 'Declined')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              complaintsUpdate(
                                  widget.complaint['_id'], "Declined");
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width / 2 - 17,
                                    50),
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                side: BorderSide(color: Colors.black, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(7)))),
                            child: Text('Decline'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              complaintsUpdate(
                                  widget.complaint['_id'], "Resolved");
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width / 2 - 17,
                                    50),
                                foregroundColor: Colors.white,
                                backgroundColor: colorBrightGreen,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(7)))),
                            child: Text('Accept'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
  }
}

class Tab extends StatelessWidget {
  const Tab({
    super.key,
    required this.label,
    required this.selected,
    required this.index,
    required this.onPressed,
  });
  final String label;
  final int selected, index;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          maximumSize: WidgetStatePropertyAll(Size(130, 40)),
          minimumSize: WidgetStatePropertyAll(Size(20, 30)),
          side: WidgetStatePropertyAll(BorderSide(color: colorBrightGreen)),
          padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
          backgroundColor: WidgetStatePropertyAll(
              index == selected ? colorBrightGreen : Colors.white),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)))),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: index == selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
