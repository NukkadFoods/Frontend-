import 'dart:typed_data';

import 'package:driver_app/controller/delivery_boy_controller/get_delivery_boy_by_id_model.dart';

class DeliveryBoy {
  String name;
  String email;
  String contact;
  String password;
  String city;
  bool isReferred;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;
  DateTime? dob;
  String? whatsappContact;
  String? alternateNumber;
  BankDetails? bankDetails;
  Uint8List? idProofPic;
  Uint8List? pancardPic;
  Uint8List? drivingLicensePic;
  List<WorkPreference>? workPreference;
  List<String>? workTimings;

  DeliveryBoy({
    required this.name,
    required this.email,
    required this.contact,
    required this.password,
    required this.city,
    this.isReferred = false,
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.dob,
    this.whatsappContact,
    this.alternateNumber,
    this.bankDetails,
    this.idProofPic,
    this.pancardPic,
    this.drivingLicensePic,
    this.workPreference,
    this.workTimings,
  });

  // Convert JSON to DeliveryBoy object
  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      name: json['name'],
      email: json['email'],
      contact: json['contact'],
      password: json['password'],
      city: json['city'],
      isReferred: json['isReferred'] ?? false,
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      whatsappContact: json['whatsappContact'],
      alternateNumber: json['alternateNumber'],
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
      idProofPic: json['idProofPic'] != null
          ? Uint8List.fromList(List<int>.from(json['idProofPic']))
          : null,
      pancardPic: json['pancardPic'] != null
          ? Uint8List.fromList(List<int>.from(json['pancardPic']))
          : null,
      drivingLicensePic: json['drivingLicensePic'] != null
          ? Uint8List.fromList(List<int>.from(json['drivingLicensePic']))
          : null,
      workPreference: json['workPreference'] != null
          ? (json['workPreference'] as List)
              .map((i) => WorkPreference.fromJson(i))
              .toList()
          : null,
      workTimings: json['workTimings'] != null
          ? List<String>.from(json['workTimings'])
          : null,
    );
  }

  // Convert DeliveryBoy object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'contact': contact,
      'password': password,
      'city': city,
      'isReferred': isReferred,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'whatsappContact': whatsappContact,
      'alternateNumber': alternateNumber,
      'bankDetails': bankDetails?.toJson(),
      'idProofPic': idProofPic,
      'pancardPic': pancardPic,
      'drivingLicensePic': drivingLicensePic,
      'workPreference': workPreference?.map((e) => e.toJson()).toList(),
      'workTimings': workTimings,
    };
  }
}
