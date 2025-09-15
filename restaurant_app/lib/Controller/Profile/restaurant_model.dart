class RestaurantModel {
  RestaurantModel({
    this.message,
    this.executed,
    this.user,
  });

  RestaurantModel.fromJson(dynamic json) {
    message = json['message'].toString();
    executed = json['executed'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? message;
  bool? executed;
  User? user;
  RestaurantModel copyWith({
    String? message,
    bool? executed,
    User? user,
  }) =>
      RestaurantModel(
        message: message ?? this.message,
        executed: executed ?? this.executed,
        user: user ?? this.user,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['executed'] = executed;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }
}

class User {
  User({
    this.id,
    this.nukkadName,
    this.nukkadAddress,
    this.latitude,
    this.longitude,
    this.pincode,
    this.city,
    this.landmark,
    this.phoneNumber,
    this.password,
    this.ownerPhoto,
    this.ownerEmail,
    this.ownerName,
    this.ownerContactNumber,
    this.currentAddress,
    this.permananetAddress,
    this.referred,
    this.signature,
    this.bankDetails,
    this.fssaiDetails,
    this.gstDetails,
    this.kycDetails,
    this.cuisines,
    this.operationalHours,
    this.restaurantMenuImages,
    this.restaurantImages,
    this.foodImages,
    this.status,
    this.timestamp,
    this.ratings,
    this.timetoprepare,
    this.isOpen = false,
  });

  User.fromJson(dynamic json) {
    id = json['_id'];
    nukkadName = json['nukkadName'];
    nukkadAddress = json['nukkadAddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    pincode = json['pincode'];
    city = json['city'];
    landmark = json['landmark'];
    phoneNumber = json['phoneNumber'];
    password = json['password'];
    ownerPhoto = json['ownerPhoto'];
    ownerEmail = json['ownerEmail'];
    ownerName = json['ownerName'];
    ownerContactNumber = json['ownerContactNumber'];
    currentAddress = json['currentAddress'];
    permananetAddress = json['permananetAddress'];
    signature = json['signature'];
    referred =
        json['referred'] != null ? Referred.fromJson(json['referred']) : null;
    bankDetails = json['bankDetails'] != null
        ? BankDetails.fromJson(json['bankDetails'])
        : null;
    fssaiDetails = json['fssaiDetails'] != null
        ? FssaiDetails.fromJson(json['fssaiDetails'])
        : null;
    gstDetails = json['gstDetails'] != null
        ? GstDetails.fromJson(json['gstDetails'])
        : null;
    kycDetails = json['kycDetails'] != null
        ? KycDetails.fromJson(json['kycDetails'])
        : null;
    cuisines = json['cuisines'] != null ? json['cuisines'].cast<String>() : [];
    operationalHours = json['operationalHours'];
    restaurantMenuImages = json['restaurantMenuImages'] != null
        ? json['restaurantMenuImages'].cast<String>()
        : [];
    restaurantImages = json['restaurantImages'] != null
        ? json['restaurantImages'].cast<String>()
        : [];
    foodImages =
        json['foodImages'] != null ? json['foodImages'].cast<String>() : [];
    status = json['status'];
    timestamp = json['timestamp'];
    ratings = json['ratings'] ?? [];
    timetoprepare = json['timetoprepare'];
    isOpen = json["isOpen"] ?? false;
    hubId = json['hubId'];
  }

  String? id;
  String? nukkadName;
  String? nukkadAddress;
  num? latitude;
  num? longitude;
  String? pincode;
  String? city;
  String? landmark;
  String? phoneNumber;
  String? password;
  dynamic ownerPhoto;
  String? ownerEmail;
  String? ownerName;
  String? ownerContactNumber;
  String? currentAddress;
  String? permananetAddress;
  Referred? referred;
  dynamic signature;
  BankDetails? bankDetails;
  FssaiDetails? fssaiDetails;
  GstDetails? gstDetails;
  KycDetails? kycDetails;
  List<String>? cuisines;
  Map? operationalHours;
  List<String>? restaurantMenuImages;
  List<String>? restaurantImages;
  List<String>? foodImages;
  String? status;
  num? timestamp;
  List<dynamic>? ratings; // Assuming ratings can be dynamic
  String? timetoprepare;
  late bool isOpen;
  String? hubId;

  User copyWith({
    String? id,
    String? nukkadName,
    String? nukkadAddress,
    num? latitude,
    num? longitude,
    String? pincode,
    String? city,
    String? landmark,
    String? phoneNumber,
    String? password,
    dynamic ownerPhoto,
    String? ownerEmail,
    String? ownerName,
    String? ownerContactNumber,
    String? currentAddress,
    String? permananetAddress,
    Referred? referred,
    dynamic signature,
    BankDetails? bankDetails,
    FssaiDetails? fssaiDetails,
    GstDetails? gstDetails,
    KycDetails? kycDetails,
    List<String>? cuisines,
    Map? operationalHours,
    List<String>? restaurantMenuImages,
    List<String>? restaurantImages,
    List<String>? foodImages,
    String? status,
    num? timestamp,
    List<dynamic>? ratings,
    String? timetoprepare,
  }) =>
      User(
        id: id ?? this.id,
        nukkadName: nukkadName ?? this.nukkadName,
        nukkadAddress: nukkadAddress ?? this.nukkadAddress,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        pincode: pincode ?? this.pincode,
        city: city ?? this.city,
        landmark: landmark ?? this.landmark,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        password: password ?? this.password,
        ownerPhoto: ownerPhoto ?? this.ownerPhoto,
        ownerEmail: ownerEmail ?? this.ownerEmail,
        ownerName: ownerName ?? this.ownerName,
        ownerContactNumber: ownerContactNumber ?? this.ownerContactNumber,
        currentAddress: currentAddress ?? this.currentAddress,
        permananetAddress: permananetAddress ?? this.permananetAddress,
        referred: referred ?? this.referred,
        signature: signature ?? this.signature,
        bankDetails: bankDetails ?? this.bankDetails,
        fssaiDetails: fssaiDetails ?? this.fssaiDetails,
        gstDetails: gstDetails ?? this.gstDetails,
        kycDetails: kycDetails ?? this.kycDetails,
        cuisines: cuisines ?? this.cuisines,
        operationalHours: operationalHours ?? this.operationalHours,
        restaurantMenuImages: restaurantMenuImages ?? this.restaurantMenuImages,
        restaurantImages: restaurantImages ?? this.restaurantImages,
        foodImages: foodImages ?? this.foodImages,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        ratings: ratings ?? this.ratings,
        timetoprepare: timetoprepare ?? this.timetoprepare,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['nukkadName'] = nukkadName;
    map['nukkadAddress'] = nukkadAddress;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['pincode'] = pincode;
    map['city'] = city;
    map['landmark'] = landmark;
    map['phoneNumber'] = phoneNumber;
    map['password'] = password;
    map['ownerPhoto'] = ownerPhoto;
    map['ownerEmail'] = ownerEmail;
    map['ownerName'] = ownerName;
    map['ownerContactNumber'] = ownerContactNumber;
    map['currentAddress'] = currentAddress;
    map['permananetAddress'] = permananetAddress;
    map['signature'] = signature;
    if (referred != null) {
      map['referred'] = referred?.toJson();
    }
    if (bankDetails != null) {
      map['bankDetails'] = bankDetails?.toJson();
    }
    if (fssaiDetails != null) {
      map['fssaiDetails'] = fssaiDetails?.toJson();
    }
    if (gstDetails != null) {
      map['gstDetails'] = gstDetails?.toJson();
    }
    if (kycDetails != null) {
      map['kycDetails'] = kycDetails?.toJson();
    }
    map['cuisines'] = cuisines;
    map['operationalHours'] = operationalHours;
    map['restaurantMenuImages'] = restaurantMenuImages;
    map['restaurantImages'] = restaurantImages;
    map['foodImages'] = foodImages;
    map['status'] = status;
    map['timestamp'] = timestamp;
    map['ratings'] = ratings;
    map['timetoprepare'] = timetoprepare;
    map['isOpen'] = isOpen;
    map['hubId']=hubId;
    return map;
  }
}

class Referred {
  Referred({
    required this.referred,
    this.reference,
    this.executiveId,
    this.executiveName,
  });

  Referred.fromJson(dynamic json) {
    referred = json['referred'];
    reference = json['reference'];
    executiveId = json['executiveId'];
    executiveName = json['executiveName'];
  }

  bool? referred;
  String? reference;
  String? executiveId;
  String? executiveName;

  Referred copyWith({
    bool? referred,
    String? reference,
    String? executiveId,
    String? executiveName,
  }) =>
      Referred(
        referred: referred ?? this.referred,
        reference: reference ?? this.reference,
        executiveId: executiveId ?? this.executiveId,
        executiveName: executiveName ?? this.executiveName,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['referred'] = referred;
    if (reference != null) map['reference'] = reference;
    if (executiveId != null) map['executiveId'] = executiveId;
    if (executiveName != null) map['executiveName'] = executiveName;
    return map;
  }
}

// class OperationalHours {
//   OperationalHours({
//     this.monday,
//     this.wednesday,
//     this.friday,
//   });

//   OperationalHours.fromJson(dynamic json) {
//     monday = json['Monday'];
//     wednesday = json['Wednesday'];
//     friday = json['Friday'];
//   }
//   String? monday;
//   String? wednesday;
//   String? friday;
//   OperationalHours copyWith({
//     String? monday,
//     String? wednesday,
//     String? friday,
//   }) =>
//       OperationalHours(
//         monday: monday ?? this.monday,
//         wednesday: wednesday ?? this.wednesday,
//         friday: friday ?? this.friday,
//       );
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['Monday'] = monday;
//     map['Wednesday'] = wednesday;
//     map['Friday'] = friday;
//     return map;
//   }
// }

class KycDetails {
  KycDetails({
    this.aadhar,
    this.pan,
  });

  KycDetails.fromJson(dynamic json) {
    aadhar = json['aadhar'];
    pan = json['pan'];
  }
  dynamic aadhar;
  dynamic pan;
  KycDetails copyWith({
    dynamic aadhar,
    dynamic pan,
  }) =>
      KycDetails(
        aadhar: aadhar ?? this.aadhar,
        pan: pan ?? this.pan,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['aadhar'] = aadhar;
    map['pan'] = pan;
    return map;
  }
}

class GstDetails {
  GstDetails({
    this.gstNumber,
    this.gstCertificate,
  });

  GstDetails.fromJson(dynamic json) {
    gstNumber = json['gstNumber'];
    gstCertificate = json['gstCertificate'];
  }
  String? gstNumber;
  dynamic gstCertificate;
  GstDetails copyWith({
    String? gstNumber,
    dynamic gstCertificate,
  }) =>
      GstDetails(
        gstNumber: gstNumber ?? this.gstNumber,
        gstCertificate: gstCertificate ?? this.gstCertificate,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gstNumber'] = gstNumber;
    map['gstCertificate'] = gstCertificate;
    return map;
  }
}

class FssaiDetails {
  FssaiDetails({
    this.certificateNumber,
    this.expiryDate,
    this.certificate,
  });

  FssaiDetails.fromJson(dynamic json) {
    certificateNumber = json['certificateNumber'];
    expiryDate = json['expiryDate'];
    certificate = json['certificate'];
  }
  String? certificateNumber;
  String? expiryDate;
  dynamic certificate;
  FssaiDetails copyWith({
    String? certificateNumber,
    String? expiryDate,
    dynamic certificate,
  }) =>
      FssaiDetails(
        certificateNumber: certificateNumber ?? this.certificateNumber,
        expiryDate: expiryDate ?? this.expiryDate,
        certificate: certificate ?? this.certificate,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['certificateNumber'] = certificateNumber;
    map['expiryDate'] = expiryDate;
    map['certificate'] = certificate;
    return map;
  }
}

class BankDetails {
  BankDetails({
    this.accountNo,
    this.iFSCcode,
    this.bankBranch,
  });

  BankDetails.fromJson(dynamic json) {
    accountNo = json['accountNo'];
    iFSCcode = json['IFSCcode'];
    bankBranch = json['bankBranch'];
  }
  String? accountNo;
  String? iFSCcode;
  String? bankBranch;
  BankDetails copyWith({
    String? accountNo,
    String? iFSCcode,
    String? bankBranch,
  }) =>
      BankDetails(
        accountNo: accountNo ?? this.accountNo,
        iFSCcode: iFSCcode ?? this.iFSCcode,
        bankBranch: bankBranch ?? this.bankBranch,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accountNo'] = accountNo;
    map['IFSCcode'] = iFSCcode;
    map['bankBranch'] = bankBranch;
    return map;
  }
}
