class MenuResponse {
  final List<Menu> menuItems;

  MenuResponse({required this.menuItems});

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    var menuItemsFromJson = json['menuItems'] as List;
    List<Menu> menuItemsList = menuItemsFromJson.map((menuItem) => Menu.fromJson(menuItem)).toList();

    return MenuResponse(menuItems: menuItemsList);
  }
}

class Menu {
  final String id;
  final String uid;
  final List<MenuItemCategory> menuItemList;

  Menu({
    required this.id,
    required this.uid,
    required this.menuItemList,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    var menuItemListFromJson = json['menuItemList'] as List;
    List<MenuItemCategory> menuItemList = menuItemListFromJson.map((item) => MenuItemCategory.fromJson(item)).toList();

    return Menu(
      id: json['_id'],
      uid: json['uid'],
      menuItemList: menuItemList,
    );
  }
}

class MenuItemCategory {
  final String category;
  final String categoryImg;
  final List<SubCategory> subCategory;

  MenuItemCategory({
    required this.category,
    required this.categoryImg,
    required this.subCategory,
  });

  factory MenuItemCategory.fromJson(Map<String, dynamic> json) {
    var subCategoryFromJson = json['subCategory'] as List;
    List<SubCategory> subCategoryList = subCategoryFromJson.map((item) => SubCategory.fromJson(item)).toList();

    return MenuItemCategory(
      category: json['category'],
      categoryImg: json['categoryImg'],
      subCategory: subCategoryList,
    );
  }
}

class SubCategory {
  final String subCategoryName;
  final List<MenuItem> menuItems;

  SubCategory({
    required this.subCategoryName,
    required this.menuItems,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    var menuItemsFromJson = json['menuItems'] as List;
    List<MenuItem> menuItemsList = menuItemsFromJson.map((item) => MenuItem.fromJson(item)).toList();

    return SubCategory(
      subCategoryName: json['subCategoryName'],
      menuItems: menuItemsList,
    );
  }
}

class MenuItem {
  final String menuItemName;
  final String menuItemImageURL;
  final String servingInfo;
  final double menuItemCost;
  final bool inStock;
  final String label;
  final int timeToPrepare;
  final String id;

  MenuItem({
    required this.menuItemName,
    required this.menuItemImageURL,
    required this.servingInfo,
    required this.menuItemCost,
    required this.inStock,
    required this.label,
    required this.timeToPrepare,
    required this.id,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuItemName: json['menuItemName'],
      menuItemImageURL: json['menuItemImageURL'],
      servingInfo: json['servingInfo'],
      menuItemCost: json['menuItemCost'].toDouble(),
      inStock: json['inStock'],
      label: json['label'],
      timeToPrepare: json['timeToPrepare'],
      id: json['_id'],
    );
  }
}
