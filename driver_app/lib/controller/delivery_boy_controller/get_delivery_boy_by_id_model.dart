class GetDeliveryBoyByIdModel {
  GetDeliveryBoyByIdModel({
    this.message,
    this.executed,
    this.deliveryBoy,
  });

  GetDeliveryBoyByIdModel.fromJson(dynamic json) {
    message = json['message'];
    executed = json['executed'];
    deliveryBoy = json['deliveryBoy'] != null
        ? DeliveryBoyModel.fromJson(json['deliveryBoy'])
        : null;
  }

  String? message;
  bool? executed;
  DeliveryBoyModel? deliveryBoy;

  GetDeliveryBoyByIdModel copyWith({
    String? message,
    bool? executed,
    DeliveryBoyModel? deliveryBoy,
  }) =>
      GetDeliveryBoyByIdModel(
        message: message ?? this.message,
        executed: executed ?? this.executed,
        deliveryBoy: deliveryBoy ?? this.deliveryBoy,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['executed'] = executed;
    if (deliveryBoy != null) {
      map['deliveryBoy'] = deliveryBoy?.toJson();
    }
    return map;
  }
}

class DeliveryBoyModel {
  DeliveryBoyModel({
    this.bankDetails,
    this.id,
    this.name,
    this.email,
    this.contact,
    this.password,
    this.city,
    this.isReferred,
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.dob,
    this.whatsappContact,
    this.alternateNumber,
    this.idProofPic,
    this.pancardPic,
    this.drivingLicensePic,
    this.workPreference,
    this.workTimings,
    this.v,
  });

  DeliveryBoyModel.fromJson(dynamic json) {
    bankDetails = json['bankDetails'] != null
        ? BankDetails.fromJson(json['bankDetails'])
        : null;
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    contact = json['contact'];
    password = json['password'];
    city = json['city'];
    isReferred = json['isReferred'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    gender = json['gender'];
    dob = json['DOB'];
    whatsappContact = json['whatsappContact'];
    alternateNumber = json['alternateNumber'];
    idProofPic = json['idProofPic'] != null
        ? IdProofPic.fromJson(json['idProofPic'])
        : null;
    pancardPic = json['pancardPic'] != null
        ? PancardPic.fromJson(json['pancardPic'])
        : null;
    drivingLicensePic = json['drivingLicensePic'] != null
        ? DrivingLicensePic.fromJson(json['drivingLicensePic'])
        : null;
    if (json['workPreference'] != null) {
      workPreference = [];
      json['workPreference'].forEach((v) {
        workPreference?.add(WorkPreference.fromJson(v));
      });
    }
    workTimings =
        json['workTimings'] != null ? json['workTimings'].cast<String>() : [];
    v = json['__v'];
  }

  BankDetails? bankDetails;
  String? id;
  String? name;
  String? email;
  String? contact;
  String? password;
  String? city;
  bool? isReferred;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;
  String? dob;
  String? whatsappContact;
  String? alternateNumber;
  IdProofPic? idProofPic;
  PancardPic? pancardPic;
  DrivingLicensePic? drivingLicensePic;
  List<WorkPreference>? workPreference;
  List<String>? workTimings;
  num? v;

  DeliveryBoyModel copyWith({
    BankDetails? bankDetails,
    String? id,
    String? name,
    String? email,
    String? contact,
    String? password,
    String? city,
    bool? isReferred,
    String? firstName,
    String? middleName,
    String? lastName,
    String? gender,
    String? dob,
    String? whatsappContact,
    String? alternateNumber,
    IdProofPic? idProofPic,
    PancardPic? pancardPic,
    DrivingLicensePic? drivingLicensePic,
    List<WorkPreference>? workPreference,
    List<String>? workTimings,
    num? v,
  }) =>
      DeliveryBoyModel(
        bankDetails: bankDetails ?? this.bankDetails,
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        contact: contact ?? this.contact,
        password: password ?? this.password,
        city: city ?? this.city,
        isReferred: isReferred ?? this.isReferred,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        gender: gender ?? this.gender,
        dob: dob ?? this.dob,
        whatsappContact: whatsappContact ?? this.whatsappContact,
        alternateNumber: alternateNumber ?? this.alternateNumber,
        idProofPic: idProofPic ?? this.idProofPic,
        pancardPic: pancardPic ?? this.pancardPic,
        drivingLicensePic: drivingLicensePic ?? this.drivingLicensePic,
        workPreference: workPreference ?? this.workPreference,
        workTimings: workTimings ?? this.workTimings,
        v: v ?? this.v,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (bankDetails != null) {
      map['bankDetails'] = bankDetails?.toJson();
    }
    map['_id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['contact'] = contact;
    map['password'] = password;
    map['city'] = city;
    map['isReferred'] = isReferred;
    map['firstName'] = firstName;
    map['middleName'] = middleName;
    map['lastName'] = lastName;
    map['gender'] = gender;
    map['DOB'] = dob;
    map['whatsappContact'] = whatsappContact;
    map['alternateNumber'] = alternateNumber;
    if (idProofPic != null) {
      map['idProofPic'] = idProofPic?.toJson();
    }
    if (pancardPic != null) {
      map['pancardPic'] = pancardPic?.toJson();
    }
    if (drivingLicensePic != null) {
      map['drivingLicensePic'] = drivingLicensePic?.toJson();
    }
    if (workPreference != null) {
      map['workPreference'] = workPreference?.map((v) => v.toJson()).toList();
    }
    map['workTimings'] = workTimings;
    map['__v'] = v;
    return map;
  }
}

class WorkPreference {
  WorkPreference({
    this.locationName,
    this.description,
    this.id,
  });

  WorkPreference.fromJson(dynamic json) {
    locationName = json['locationName'];
    description = json['description'];
    id = json['_id'];
  }
  String? locationName;
  String? description;
  String? id;
  WorkPreference copyWith({
    String? locationName,
    String? description,
    String? id,
  }) =>
      WorkPreference(
        locationName: locationName ?? this.locationName,
        description: description ?? this.description,
        id: id ?? this.id,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['locationName'] = locationName;
    map['description'] = description;
    map['_id'] = id;
    return map;
  }
}

class DrivingLicensePic {
  DrivingLicensePic({
    this.type,
    this.data,
  });

  DrivingLicensePic.fromJson(dynamic json) {
    type = json['type'];
    data = json['data'] != null ? json['data'].cast<num>() : [];
  }
  String? type;
  List<num>? data;
  DrivingLicensePic copyWith({
    String? type,
    List<num>? data,
  }) =>
      DrivingLicensePic(
        type: type ?? this.type,
        data: data ?? this.data,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['data'] = data;
    return map;
  }
}

class PancardPic {
  PancardPic({
    this.type,
    this.data,
  });

  PancardPic.fromJson(dynamic json) {
    type = json['type'];
    data = json['data'] != null ? json['data'].cast<num>() : [];
  }
  String? type;
  List<num>? data;
  PancardPic copyWith({
    String? type,
    List<num>? data,
  }) =>
      PancardPic(
        type: type ?? this.type,
        data: data ?? this.data,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['data'] = data;
    return map;
  }
}

class IdProofPic {
  IdProofPic({
    this.type,
    this.data,
  });

  IdProofPic.fromJson(dynamic json) {
    type = json['type'];
    data = json['data'] != null ? json['data'].cast<num>() : [];
  }
  String? type;
  List<num>? data;
  IdProofPic copyWith({
    String? type,
    List<num>? data,
  }) =>
      IdProofPic(
        type: type ?? this.type,
        data: data ?? this.data,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['type'] = type;
    map['data'] = data;
    return map;
  }
}

class BankDetails {
  BankDetails({
    this.iFSCCode,
    this.branchCode,
    this.accountNumber,
  });

  BankDetails.fromJson(dynamic json) {
    iFSCCode = json['IFSCCode'];
    branchCode = json['branchCode'];
    accountNumber = json['accountNumber'];
  }
  String? iFSCCode;
  String? branchCode;
  String? accountNumber;
  BankDetails copyWith({
    String? iFSCCode,
    String? branchCode,
    String? accountNumber,
  }) =>
      BankDetails(
        iFSCCode: iFSCCode ?? this.iFSCCode,
        branchCode: branchCode ?? this.branchCode,
        accountNumber: accountNumber ?? this.accountNumber,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['IFSCCode'] = iFSCCode;
    map['branchCode'] = branchCode;
    map['accountNumber'] = accountNumber;
    return map;
  }
}
