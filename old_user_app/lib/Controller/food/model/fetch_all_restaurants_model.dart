import 'dart:math';

import 'package:user_app/widgets/constants/shared_preferences.dart';

class FetchAllRestaurantsModel {
  FetchAllRestaurantsModel({
    this.message,
    this.executed,
    this.restaurants,
  });

  FetchAllRestaurantsModel.fromJson(dynamic json) {
    message = json['message'];
    executed = json['executed'];
    if (json['restaurants'] != null) {
      restaurants = [];
      double userLat = SharedPrefsUtil().getDouble("CurrentLatitude")!;
      double userLng = SharedPrefsUtil().getDouble("CurrentLongitude")!;
      json['restaurants'].forEach((v) {
        final temp = Restaurants.fromJson(v);
        if (getDistanceInKm(temp.latitude!, temp.longitude!, userLat, userLng) <
                15 &&
            temp.status == 'verified' &&
            temp.isBanned == false) {
          restaurants?.add(temp);
        }
      });
    }
  }
  String? message;
  bool? executed;
  List<Restaurants>? restaurants;
  FetchAllRestaurantsModel copyWith({
    String? message,
    bool? executed,
    List<Restaurants>? restaurants,
  }) =>
      FetchAllRestaurantsModel(
        message: message ?? this.message,
        executed: executed ?? this.executed,
        restaurants: restaurants ?? this.restaurants,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['executed'] = executed;
    if (restaurants != null) {
      map['restaurants'] = restaurants?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  // Add an empty constructor
  factory FetchAllRestaurantsModel.empty() {
    return FetchAllRestaurantsModel(
      restaurants: [], // Default to an empty list or other default values
    );
  }

  List<Restaurants>? sortRestaurantsByTimestamp() {
    if (restaurants == null) return null;
    List<Restaurants> sortedRestaurants = List.from(restaurants!);
    sortedRestaurants.sort(
        (a, b) => b.timestamp!.compareTo(a.timestamp!)); // Descending order
    return sortedRestaurants;
  }

  List<Restaurants>? sortRestaurantsByDistance(num userLat, num userLng) {
    if (restaurants == null) return null;

    // Calculate distances for each restaurant
    for (var restaurant in restaurants!) {
      restaurant.distanceFromUser = calculateDistance(
          userLat, userLng, restaurant.latitude!, restaurant.longitude!);
    }

    // Sort restaurants by distance
    List<Restaurants> sortedRes = List.from(restaurants!);
    sortedRes.sort((a, b) =>
        getDistanceInKm(userLat, userLng, a.latitude!, a.longitude!).compareTo(
            getDistanceInKm(userLat, userLng, b.latitude!, b.longitude!)));
    return sortedRes;
  }

  List<Restaurants>? sortRestaurantsByTimeToPrepare() {
    if (restaurants == null) return null;
    List<Restaurants> sortedRes = List.from(restaurants!);
    sortedRes.sort((a, b) =>
        (a.timetoprepare! + getDistance(a.distanceFromUser!))
            .compareTo(b.timetoprepare! + getDistance(b.distanceFromUser!)));
    return sortedRes;
  }
}

double getDistance(String distance) {
  double distanceKm = 0.0;
  final String temp = distance.split(' ')[0];
  if (temp.endsWith('k')) {
    distanceKm = double.tryParse(temp.split('k')[0]) ?? 0.0;
    distanceKm = distanceKm * 1000;
  } else {
    distanceKm = double.tryParse(distance.split(' ')[0]) ?? 0.0;
  }
  return distanceKm;
}

extension FetchAllRestaurantsModelExtension on FetchAllRestaurantsModel {
  List<Restaurants> getFavoriteRestaurants(List<String> favoriteIds) {
    return restaurants!
        .where((restaurant) => favoriteIds.contains(restaurant.id))
        .toList();
  }

  bool isFavoriteRestaurant(
      {required Restaurants restaurant,
      required List<Restaurants> favoriteIds}) {
    return favoriteIds.contains(restaurant);
  }
}

class FetchAllRestaurantsModelbyid {
  List<Restaurants>? restaurants;

  FetchAllRestaurantsModelbyid({this.restaurants});

  Restaurants? getRestaurantById(String restaurantId) {
    if (restaurants == null) return null; // Check for null before searching
    return restaurants!.firstWhere(
        (restaurant) => restaurant.id == restaurantId,
        orElse: () =>
            Restaurants(id: '') // Provide a default value instead of null
        );
  }
}

class Restaurants {
  Restaurants(
      {this.id,
      this.nukkadName,
      this.nukkadAddress,
      this.latitude,
      this.longitude,
      this.pincode,
      this.city,
      this.landmark,
      this.phoneNumber,
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
      this.distanceFromUser,
      this.timetoprepare,
      this.isOpen,
      this.isBanned,
      this.hubId});

  Restaurants.fromJson(dynamic json) {
    id = json['_id'];
    nukkadName = json['nukkadName'];
    nukkadAddress = json['nukkadAddress'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    pincode = json['pincode'];
    city = json['city'];
    landmark = json['landmark'];
    phoneNumber = json['phoneNumber'];
    ownerPhoto = json['ownerPhoto'];
    ownerEmail = json['ownerEmail'];
    ownerName = json['ownerName'];
    ownerContactNumber = json['ownerContactNumber'];
    currentAddress = json['currentAddress'];
    permananetAddress = json['permananetAddress'];
    referred =
        json['referred'] != null ? Referred.fromJson(json['referred']) : null;
    signature = json['signature'];
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
    operationalHours = json['operationalHours'] != null
        ? OperationalHours.fromJson(json['operationalHours'])
        : null;
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
    ratings = json['ratings'] != null ? json['ratings'].cast<String>() : [];
    distanceFromUser = null;
    timetoprepare = double.parse(json['timetoprepare'].toString());
    isOpen = json['isOpen'] ?? false;
    hubId = json['hubId'];
    isBanned = json['isBanned'];
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
  String? ownerPhoto;
  String? ownerEmail;
  String? ownerName;
  String? ownerContactNumber;
  String? currentAddress;
  String? permananetAddress;
  Referred? referred;
  String? signature;
  BankDetails? bankDetails;
  FssaiDetails? fssaiDetails;
  GstDetails? gstDetails;
  KycDetails? kycDetails;
  List<String>? cuisines;
  OperationalHours? operationalHours;
  List<String>? restaurantMenuImages;
  List<String>? restaurantImages;
  List<String>? foodImages;
  String? status;
  num? timestamp;
  List<String>? ratings;
  String? distanceFromUser;
  double? timetoprepare;
  bool? isOpen;
  bool? isBanned;
  String? hubId;
  Restaurants copyWith({
    String? id,
    String? nukkadName,
    String? nukkadAddress,
    num? latitude,
    num? longitude,
    String? pincode,
    String? city,
    String? landmark,
    String? phoneNumber,
    String? ownerPhoto,
    String? ownerEmail,
    String? ownerName,
    String? ownerContactNumber,
    String? currentAddress,
    String? permananetAddress,
    Referred? referred,
    String? signature,
    BankDetails? bankDetails,
    FssaiDetails? fssaiDetails,
    GstDetails? gstDetails,
    KycDetails? kycDetails,
    List<String>? cuisines,
    OperationalHours? operationalHours,
    List<String>? restaurantMenuImages,
    List<String>? restaurantImages,
    List<String>? foodImages,
    String? status,
    num? timestamp,
    List<String>? ratings,
    double? timetoprepare,
    bool? isOpen,
  }) =>
      Restaurants(
          id: id ?? this.id,
          nukkadName: nukkadName ?? this.nukkadName,
          nukkadAddress: nukkadAddress ?? this.nukkadAddress,
          latitude: latitude ?? this.latitude,
          longitude: longitude ?? this.longitude,
          pincode: pincode ?? this.pincode,
          city: city ?? this.city,
          landmark: landmark ?? this.landmark,
          phoneNumber: phoneNumber ?? this.phoneNumber,
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
          restaurantMenuImages:
              restaurantMenuImages ?? this.restaurantMenuImages,
          restaurantImages: restaurantImages ?? this.restaurantImages,
          foodImages: foodImages ?? this.foodImages,
          status: status ?? this.status,
          timestamp: timestamp ?? this.timestamp,
          ratings: ratings ?? this.ratings,
          timetoprepare: timetoprepare ?? this.timetoprepare,
          isOpen: isOpen ?? this.isOpen);
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
    map['ownerPhoto'] = ownerPhoto;
    map['ownerEmail'] = ownerEmail;
    map['ownerName'] = ownerName;
    map['ownerContactNumber'] = ownerContactNumber;
    map['currentAddress'] = currentAddress;
    map['permananetAddress'] = permananetAddress;
    if (referred != null) {
      map['referred'] = referred?.toJson();
    }
    map['signature'] = signature;
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
    if (operationalHours != null) {
      map['operationalHours'] = operationalHours?.toJson();
    }
    map['restaurantMenuImages'] = restaurantMenuImages;
    map['restaurantImages'] = restaurantImages;
    map['foodImages'] = foodImages;
    map['status'] = status;
    map['timestamp'] = timestamp;
    map['ratings'] = ratings;
    map['timetoprepare'] = timetoprepare;
    map['isOpen'] = isOpen;
    map['hubId'] = hubId;
    map['isBanned'] = isBanned;
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

String calculateDistance(num lat1, num lon1, num lat2, num lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distanceKm = R * c; // Distance in kilometers
  // final distanceMiles = distanceKm * 0.621371; // Convert to miles

  return formatDistance(distanceKm); // Utilize formatDistance function
}

double getDistanceInKm(num lat1, num lon1, num lat2, num lon2) {
  const R = 6371; // Radius of the Earth in kilometers
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(num deg) {
  return deg * (pi / 180);
}

String estimateTravelTime(String distance, {int timeToAddInMins = 0}) {
  // Extract the numeric part of the distance from the input string
  double distanceKm = 0.0;
  final String temp = distance.split(' ')[0];
  if (temp.endsWith('k')) {
    distanceKm = double.tryParse(temp.split('k')[0]) ?? 0.0;
    distanceKm = distanceKm * 1000;
  } else {
    distanceKm = double.tryParse(distance.split(' ')[0]) ?? 0.0;
    if (distance.endsWith("meters")) {
      distanceKm = distanceKm / 1000;
    }
  }

  const averageSpeedKmH = 30; // Average speed in km/h
  double timeInHours = distanceKm / averageSpeedKmH; // Time in hours
  return formatTravelTime(timeInHours +
      (timeToAddInMins / 60)); // Utilize formatTravelTime function
}

String formatDistance(double distanceKm) {
  const double metersThreshold = 1.0; // Threshold to switch to meters
  const double kilometersThreshold = 1000.0; // Threshold to switch to thousands

  if (distanceKm < metersThreshold) {
    // Convert to meters if distance is less than the threshold
    return '${(distanceKm * 1000).toStringAsFixed(1)} meters';
  } else if (distanceKm < kilometersThreshold) {
    // Display distance in kilometers
    return '${distanceKm.toStringAsFixed(1)} km';
  } else {
    // Display distance in thousands of kilometers
    return '${(distanceKm / 1000).toStringAsFixed(1)}k km'; // "kkm" denotes thousands of kilometers
  }
}

String formatTravelTime(double timeInHours) {
  const double minutesThreshold = 1.0 / 60.0; // Threshold to switch to minutes
  const double daysThreshold = 24.0; // Threshold to switch to days

  if (timeInHours < minutesThreshold) {
    // Convert to seconds if time is very short
    double timeInSeconds = timeInHours * 3600;
    return '${timeInSeconds.toStringAsFixed(1)} seconds';
  } else if (timeInHours < 1.0) {
    // Convert to minutes if less than 1 hour
    return '${(timeInHours * 60).toStringAsFixed(1)} min';
  } else if (timeInHours < daysThreshold) {
    // Display hours if less than a day
    return '${timeInHours.toStringAsFixed(1)} h';
  } else {
    // Convert to days if more than or equal to a day
    double days = timeInHours / 24;
    return '${days.toStringAsFixed(1)} d';
  }
}

extension RestaurantExtensions on Restaurants {
  double getAverageRating() {
    double rating = 0.0;
    if (ratings != null && ratings!.isNotEmpty) {
      for (var r in ratings!) {
        rating += double.parse(r);
      }
      rating = rating / ratings!.length;
    }
    return rating;
  }
}

class OperationalHours {
  OperationalHours({
    this.sunday,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
  });

  OperationalHours.fromJson(dynamic json) {
    sunday = json['Sunday'];
    monday = json['Monday'];
    tuesday = json['Tuesday'];
    wednesday = json['Wednesday'];
    thursday = json['Thursday'];
    friday = json['Friday'];
    saturday = json['Saturday'];
  }
  String? sunday;
  String? monday;
  String? tuesday;
  String? wednesday;
  String? thursday;
  String? friday;
  String? saturday;
  OperationalHours copyWith(
          {String? sunday,
          String? monday,
          String? tuesday,
          String? wednesday,
          String? thursday,
          String? friday,
          String? saturday}) =>
      OperationalHours(
          sunday: sunday ?? this.sunday,
          monday: monday ?? this.monday,
          tuesday: tuesday ?? this.tuesday,
          wednesday: wednesday ?? this.wednesday,
          thursday: thursday ?? this.thursday,
          friday: friday ?? this.friday,
          saturday: saturday ?? this.saturday);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Sunday'] = sunday;
    map['Monday'] = monday;
    map['Tuesday'] = tuesday;
    map['Wednesday'] = wednesday;
    map['Thursday'] = thursday;
    map['Friday'] = friday;
    map['Saturday'] = saturday;
    return map;
  }
}

class KycDetails {
  KycDetails({
    this.aadhar,
    this.pan,
  });

  KycDetails.fromJson(dynamic json) {
    aadhar = json['aadhar'];
    pan = json['pan'];
  }
  String? aadhar;
  String? pan;
  KycDetails copyWith({
    String? aadhar,
    String? pan,
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
  String? gstCertificate;
  GstDetails copyWith({
    String? gstNumber,
    String? gstCertificate,
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
  String? certificate;
  FssaiDetails copyWith({
    String? certificateNumber,
    String? expiryDate,
    String? certificate,
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
