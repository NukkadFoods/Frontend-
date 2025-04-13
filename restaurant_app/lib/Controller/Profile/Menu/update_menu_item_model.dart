import 'package:restaurant_app/Controller/Profile/Menu/menu_model.dart';

class UpdateMenuItemModel {
  UpdateMenuItemModel({
    this.updatedata,
  });

  UpdateMenuItemModel.fromJson(dynamic json) {
    updatedata = json['updatedata'] != null
        ? MenuItemModel.fromJson(json['updatedata'])
        : null;
  }
  MenuItemModel? updatedata;
  UpdateMenuItemModel copyWith({
    MenuItemModel? updatedata,
  }) =>
      UpdateMenuItemModel(
        updatedata: updatedata ?? this.updatedata,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (updatedata != null) {
      map['updatedata'] = updatedata?.toJson();
    }
    return map;
  }
}