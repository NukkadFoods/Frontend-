class MenuItemModel {
  String? menuItemName;
  dynamic menuItemImageURL;
  String? servingInfo;
  String? label;
  num? menuItemCost;
  bool? inStock;
  num? timeToPrepare;
  String? id;

  MenuItemModel({
    this.menuItemName,
    this.menuItemImageURL,
    this.servingInfo,
    this.label,
    this.menuItemCost,
    this.inStock,
    this.timeToPrepare,
    this.id,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      menuItemName: json['menuItemName'] as String?,
      menuItemImageURL: json['menuItemImageURL'],
      servingInfo: json['servingInfo'] as String?,
      label: json['label'] as String?,
      menuItemCost: json['menuItemCost'] as num?,
      inStock: json['inStock'] as bool?,
      timeToPrepare: json['timeToPrepare'] as num?,
      id: json["_id"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemName': menuItemName,
      'menuItemImageURL': menuItemImageURL,
      'servingInfo': servingInfo,
      'label': label,
      'menuItemCost': menuItemCost,
      'inStock': inStock,
      'timeToPrepare': timeToPrepare,
      "_id": id,
    };
  }

  MenuItemModel copyWith({
    String? menuItemName,
    dynamic menuItemImageURL,
    String? servingInfo,
    String? label,
    num? menuItemCost,
    bool? inStock,
    num? timeToPrepare,
    String? id,
  }) {
    return MenuItemModel(
      menuItemName: menuItemName ?? this.menuItemName,
      menuItemImageURL: menuItemImageURL ?? this.menuItemImageURL,
      servingInfo: servingInfo ?? this.servingInfo,
      label: label ?? this.label,
      menuItemCost: menuItemCost ?? this.menuItemCost,
      inStock: inStock ?? this.inStock,
      timeToPrepare: timeToPrepare ?? this.timeToPrepare,
      id: id ?? this.id,
    );
  }
}

String calculateAverageTimeToPrepare(FullMenuModel menuModel) {
  // Check if menuItems is empty
  if (menuModel.menuItems == null || menuModel.menuItems!.isEmpty)
    return "0.00";

  num total = 0;
  int count = 0;

  // Iterate through each category and subcategory
  for (var category in menuModel.menuItems!) {
    for (var subCategory in category.subCategory!) {
      for (var item in subCategory.menuItems!) {
        if (item.timeToPrepare != null) {
          total += item.timeToPrepare!;
          count++;
        }
      }
    }
  }

  // Calculate the average
  num averageTime = count == 0 ? 0 : total / count;
  return averageTime.toStringAsFixed(2); // Return formatted average time
}

class SubCategory {
  String? subCategoryName;
  List<MenuItemModel>? menuItems;

  SubCategory({this.subCategoryName, this.menuItems});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryName: json['subCategoryName'] as String?,
      menuItems: json['menuItems'] != null
          ? (json['menuItems'] as List)
              .where((item) => item != null)
              .map((item) =>
                  MenuItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategoryName': subCategoryName,
      'menuItems': menuItems?.map((item) => item.toJson()).toList(),
    };
  }
}

class MenuCategory {
  String? category;
  List<SubCategory>? subCategory;

  MenuCategory({this.category, this.subCategory});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      category: json['category'] as String?,
      subCategory: json['subCategory'] != null
          ? (json['subCategory'] as List)
              .where((item) => item != null)
              .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'subCategory': subCategory?.map((item) => item.toJson()).toList(),
    };
  }
}

class FullMenuModel {
  List<MenuCategory>? menuItems;

  FullMenuModel({this.menuItems});

  factory FullMenuModel.fromJson(Map<String, dynamic> json) {
    return FullMenuModel(
      menuItems: json['menuItems'] != null
          ? (json['menuItems'] as List)
              .where((item) => item != null)
              .map(
                  (item) => MenuCategory.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItems': menuItems?.map((item) => item.toJson()).toList(),
    };
  }
}

class CategoryMenuModel {
  List<SubCategory>? subCategories;

  CategoryMenuModel({this.subCategories});

  factory CategoryMenuModel.fromJson(Map<String, dynamic> json) {
    return CategoryMenuModel(
      subCategories: json['subCategories'] != null
          ? (json['subCategories'] as List)
              .where((item) => item != null)
              .map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategories': subCategories?.map((item) => item.toJson()).toList(),
    };
  }
}

class SimpleMenuModel {
  List<MenuItemModel>? menuItems;

  SimpleMenuModel({this.menuItems});

  factory SimpleMenuModel.fromJson(Map<String, dynamic> json) {
    return SimpleMenuModel(
      menuItems: json['menuItems'] != null
          ? (json['menuItems'] as List)
              .where((item) => item != null)
              .map((item) =>
                  MenuItemModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItems': menuItems?.map((item) => item.toJson()).toList(),
    };
  }
}
