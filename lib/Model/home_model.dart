class HeaderBanner {
  int id;
  String banner_image;
  String banner_name;

  HeaderBanner(
    this.id,
    this.banner_image,
    this.banner_name,
  );

  HeaderBanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    banner_image = json['banner_image'];
    banner_name = json['banner_name'];
  }
}

class CategoryList {
  int id;
  String category_name;
  // int subcategory;
  String category_image;

  CategoryList(
    this.id,
    this.category_name,
    // this.subcategory,
    this.category_image,
  );

  CategoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category_name = json['category_name'];
    // subcategory = json['subcategory'];
    category_image = json['category_image'];
  }
}

class SubCategoryList {
  int id;
  String category_name;
  String sub_category_name;
  String sub_category_type;

  SubCategoryList(
    this.id,
    this.category_name,
    this.sub_category_name,
    this.sub_category_type,
  );

  SubCategoryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category_name = json['category_name'];
    sub_category_name = json['sub_category_name'];
    sub_category_type = json['sub_category_type'];
  }
}

class AdsList {
  int id;
  String ads_name;
  String service_type;
  String city_name;
  String ads_image;
  String category_name;
  String favorite_status;
  String ads_price;
  String posted_at;
  String created_at;
  int feature_status;
  int ads_status;
  String ads_status_text;
  String ads_date;
  int total_views;
  int category_id;

  AdsList(
    this.id,
    this.ads_name,
    this.service_type,
    this.city_name,
    this.ads_image,
    this.category_name,
    this.favorite_status,
    this.ads_price,
    this.posted_at,
    this.created_at,
    this.feature_status,
    this.ads_status,
    this.ads_status_text,
    this.ads_date,
    this.total_views,
    this.category_id,
  );

  AdsList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ads_name = json['ads_name'];
    service_type = json['service_type'];
    city_name = json['city_name'];
    ads_image = json['ads_image'];
    category_name = json['category_name'];
    favorite_status = json['favorite_status'];
    ads_price = json['ads_price'].toString();
    posted_at = json['posted_at'];
    created_at = json['created_at'].toString();
    feature_status = json['feature_status'];
    ads_status = json['ads_status'];
    ads_status_text = json['ads_status_text'];
    ads_date = json['ads_date'];
    total_views = json['total_views'];
    category_id = json['category_id'];
  }
}

class HelpSupport {
  int id;
  String page_name;
  String page_slug;

  HelpSupport(
    this.id,
    this.page_name,
    this.page_slug,
  );

  HelpSupport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    page_name = json['page_name'];
    page_slug = json['page_slug'];
  }
}
