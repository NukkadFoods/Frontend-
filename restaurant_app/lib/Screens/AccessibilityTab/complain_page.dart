import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_app/Controller/order/orders_model.dart';
import 'package:restaurant_app/Screens/AccessibilityTab/complainsFilter.dart';
import 'package:restaurant_app/Widgets/constants/colors.dart';
import 'package:restaurant_app/Widgets/constants/strings.dart';
import 'package:restaurant_app/Widgets/constants/texts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../Widgets/toast.dart';

class ComplaintsWidget extends StatefulWidget {
  const ComplaintsWidget({super.key});

  @override
  State<ComplaintsWidget> createState() => _ComplaintsWidgetState();
}

class _ComplaintsWidgetState extends State<ComplaintsWidget> {
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> complaintsDataList = [];
  List<Map<String, dynamic>> filterComplaints = [];
  Map<String, OrderData> loadedOrderData = {};
  bool isOngoing = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getComplaints();
  }

  Future<void> getComplaints() async {
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      var baseUrl = AppStrings.baseURL;
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String userid = prefs.getString('User_id')!;
      final response =
          await http.get(Uri.parse('$baseUrl/complaint/getAllComplaints'));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          setState(() {
            isLoading = false;
            complaintsDataList.clear();
            for (Map<String, dynamic> complaint in responseData['complaints']) {
              if (complaint['complaint_done_against_role']
                      .toString()
                      .toLowerCase() ==
                  "rider") {
                // if (complaint['complaint_done_against_id'] == userid) {
                  complaintsDataList.add(complaint);
                // }
              }
            }
            filterComplaints = complaintsDataList
                .where((order) =>
                    order['status'] == 'Resolved' ||
                    order['status'] == 'Verified' ||
                    order['status'] == 'Processing')
                .toList();
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Toast.showToast(message: 'Internal Server Error', isError: true);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(response.body);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: colorFailure, content: Text("Error: Server Error")));
    }
  }

  Future<void> complaintsUpdate(Map complaint, String status) async {
    setState(() {
      isLoading = true;
    });
    try {
      // var baseUrl = dotenv.env['BASE_URL'];
      var baseUrl = AppStrings.baseURL;
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
          getComplaints();
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Complaints', style: h4TextStyle),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 19.sp,
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(
          children: [
            Image.asset(
              'assets/images/otpbg.png',
              fit: BoxFit.cover,
              width: double.maxFinite,
            ),
            SafeArea(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorFailure,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: ComplaintFilter(
                                type: isOngoing, selected: _handelSelectedTab),
                          ),
                          Expanded(
                            // height: 69.h,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: filterComplaints.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  // child: buildComplaintItem(filterComplaints[index]),
                                  child: ComplaintItem(
                                      loadedOrderData: loadedOrderData,
                                      complaint: filterComplaints[index],
                                      onApprove: () {
                                        
                                        complaintsUpdate(
                                            filterComplaints[index],
                                            "Resolved",
                                            );
                                      },
                                      onDecline: () {
                                        var data = jsonDecode(
                                            filterComplaints[index]
                                                ['description']);
                                        data['update'] = 'Issue Declined';
                                        complaintsUpdate(
                                            filterComplaints[index],
                                            'Declined',
                                            );
                                      }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ));
  }

  void routerChat() {
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const ChatScreenWidget(),
    //   ),
    // );
  }

  void _handelSelectedTab(int idx) {
    switch (idx) {
      case 0:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) =>
                  order['status'] == 'Resolved' ||
                  order['status'] == 'Verified' ||
                  order['status'] == 'Processing')
              .toList();
        });
      case 1:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) => order['status'] == 'Processing')
              .toList();
        });
        break;
      case 2:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) => order['status'] == 'Resolved')
              .toList();
        });
        break;
      case 3:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) => order['status'] == 'Verified')
              .toList();
        });
        break;
      case 4:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) => order['status'] == 'Processing')
              .toList();
        });
        break;
      default:
        setState(() {
          filterComplaints = complaintsDataList
              .where((order) =>
                  order['status'] == 'Resolved' ||
                  order['status'] == 'Verified' ||
                  order['status'] == 'Processing')
              .toList();
        });
        break;
    }
  }
}

class ComplaintItem extends StatefulWidget {
  const ComplaintItem(
      {super.key,
      required this.complaint,
      required this.onApprove,
      required this.onDecline,
      required this.loadedOrderData});
  final Map complaint;
  final VoidCallback onApprove, onDecline;
  final Map<String, OrderData> loadedOrderData;
  @override
  State<ComplaintItem> createState() => _ComplaintItemState();
}

class _ComplaintItemState extends State<ComplaintItem> {
  late Map filterComplaint;
  OrderData? orderData;
  bool isLoading = true;
  late Map description;
  @override
  void initState() {
    super.initState();
    filterComplaint = widget.complaint;
    description = jsonDecode(filterComplaint['description']);
    getData();
  }

  void getData() async {
    if (widget.loadedOrderData.containsKey(filterComplaint['orderID'])) {
      isLoading = false;
      orderData = widget.loadedOrderData[filterComplaint['orderID']]!;
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
                '$baseUrl/order/orders/${filterComplaint['complaint_done_by_id']}/${filterComplaint['orderID']}'),
            headers: {AppStrings.contentType: AppStrings.applicationJson});
        if (response.statusCode == 200) {
          orderData = OrderData.fromJson(jsonDecode(response.body)['order']);
          widget.loadedOrderData[orderData!.orderId!] = orderData!;
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          )
        : (orderData == null)
            ? Center(child: Text('No Internet or No order found'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.symmetric(vertical: 2.h),
                  //   child:
                  //       ComplaintFilter(type: isOngoing, selected: _handelSelectedTab),
                  // ),
                  Container(
                    width: 100.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.2.h, color: primaryColor),
                      color: primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order no. #${filterComplaint['orderID']}',
                          style: body6TextStyle.copyWith(
                              color: textBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${description['title']}',
                              style: body4TextStyle.copyWith(
                                  color: colorFailure,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 1.h),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.2.h, color: primaryColor),
                                color: primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)),
                              ),
                              child: Text(
                                'New',
                                style: body6TextStyle.copyWith(
                                    color: textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                          vertical: BorderSide(width: 0.2.h, color: textGrey3)),
                      color: textWhite,
                      // borderRadius: BorderRadius.only(bott),
                      boxShadow: [
                        BoxShadow(
                          color: textGrey3.withOpacity(0.5), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset:
                              Offset(0, 3), // Offset in the x and y directions
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 65.w,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        // _image != null
                                        //     ? FileImage(_image!) as ImageProvider<Object>?
                                        //     :
                                        AssetImage('assets/images/owner.png'),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          orderData!.orderByName!,
                                          maxLines: 1,
                                          style: body4TextStyle.copyWith(
                                              color: textBlack,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.start,
                                        ),
                                        Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          orderData!.deliveryAddress!,
                                          style: body6TextStyle.copyWith(
                                              color: textGrey3,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              maxLines: 1,
                              orderData!.time!,
                              style: body4TextStyle.copyWith(
                                  color: textGrey1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Divider(),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${description['title']}',
                              style: body4TextStyle.copyWith(
                                  color: primaryColor,
                                  fontSize: 15,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.2.h, color: colorSuccess),
                                color: colorSuccess,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)),
                                boxShadow: [
                                  BoxShadow(
                                    color: textGrey3
                                        .withOpacity(0.5), // Shadow color
                                    spreadRadius: 2, // Spread radius
                                    blurRadius: 5, // Blur radius
                                    offset: Offset(0,
                                        3), // Offset in the x and y directions
                                  ),
                                ],
                              ),
                              child: Text(
                                '${filterComplaint['status']}',
                                style: body5TextStyle.copyWith(
                                    color: textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        for (var item in orderData!.items!)
                          Text(
                            '${item.itemQuantity!} X ${item.itemName!}',
                            style: body6TextStyle.copyWith(
                                color: textBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.start,
                          ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Items: ${orderData!.itemAmount}',
                              style: body6TextStyle.copyWith(
                                  color: textGrey2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              ' ₹ ${orderData!.totalCost!}',
                              style: body6TextStyle.copyWith(
                                  color: textBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        if (description['image'] != null)
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  description['image'],
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          width: 100.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.7.h),
                          decoration: BoxDecoration(
                            color: colorwarnig.withOpacity(0.3),
                            border:
                                Border.all(width: 0.2.h, color: colorwarnig2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Review:',
                                  style: body3TextStyle.copyWith(
                                    fontSize: 14,
                                    color: colorFailure,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' “${description['description']}”',
                                  style: body6TextStyle.copyWith(
                                    letterSpacing: 0.7,
                                    fontSize: 12,
                                    color: textBlack,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Align(
                            child: Text(
                              'Refund amount requested: ₹ ${orderData!.totalCost!}',
                              style: body5TextStyle.copyWith(
                                  color: primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                      ],
                    ),
                  ),
                  if (widget.complaint['status'] != 'Resolved' &&
                      widget.complaint['status'] != 'Declined')
                    Row(
                      children: [
                        InkWell(
                          onTap: widget.onDecline,
                          child: Container(
                            width: 45.w,
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              // color: colorwarnig.withOpacity(0.3),
                              border:
                                  Border.all(width: 0.2.h, color: textGrey1),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(7)),
                            ),
                            child: Text(
                              'Decline',
                              textAlign: TextAlign.center,
                              style: body3TextStyle.copyWith(
                                fontSize: 16,
                                color: textGrey1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: widget.onApprove,
                          // () {
                          // complaintsUpdate(filterComplaint['_id']);
                          // },
                          child: Container(
                            width: 45.w,
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: colorSuccess,
                              border:
                                  Border.all(width: 0.2.h, color: colorSuccess),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(7)),
                            ),
                            child: Text(
                              'Approve',
                              textAlign: TextAlign.center,
                              style: body4TextStyle.copyWith(
                                fontSize: 16,
                                color: textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
  }
}
