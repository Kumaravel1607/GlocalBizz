class AllStoreList {
  int id;
  String store_name;
  String store_address;
  String store_logo;
  String store_slug;

  AllStoreList(
    this.id,
    this.store_name,
    this.store_address,
    this.store_logo,
    this.store_slug,
  );

  AllStoreList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    store_name = json['store_name'];
    store_address = json['store_address'];
    store_logo = json['store_logo'];
    store_slug = json['store_slug'];
  }
}

class StoreDetail {
  final int id;
  final int customer_id;
  final String store_name;
  final String store_logo;
  final String store_banner;
  final String store_theme;
  final String store_category;
  final int delivery_option;
  final String store_address;
  final String store_slug;
  final int store_status;
  final int store_open;
  final int operator_id;
  final String created_at;
  final String updated_at;
  final String profile_image;
  final String first_name;
  final String last_name;
  final String mobile;
  final String store_link;
  final String owner_name;
  final String store_email;
  final String store_contact;
  final String about_us;
  final String business_since;
  final String pincode;
  final String from_time;
  final String to_time;
  final String latitude;
  final String longitude;
  StoreDetail({
    this.id,
    this.customer_id,
    this.store_name,
    this.store_logo,
    this.store_banner,
    this.store_theme,
    this.store_category,
    this.delivery_option,
    this.store_address,
    this.store_slug,
    this.store_status,
    this.operator_id,
    this.created_at,
    this.updated_at,
    this.profile_image,
    this.first_name,
    this.last_name,
    this.mobile,
    this.store_link,
    this.store_open,
    this.owner_name,
    this.store_email,
    this.store_contact,
    this.about_us,
    this.business_since,
    this.pincode,
    this.from_time,
    this.to_time,
    this.latitude,
    this.longitude,
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      id: json['id'],
      customer_id: json['customer_id'],
      store_name: json['store_name'],
      store_logo: json['store_logo'],
      store_banner: json['store_banner'],
      store_theme: json['store_theme'],
      store_category: json['store_category'],
      delivery_option: json['delivery_option'],
      store_address: json['store_address'],
      store_slug: json['store_slug'],
      store_status: json['store_status'],
      store_open: json['store_open'],
      operator_id: json['operator_id'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      profile_image: json['profile_image'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      mobile: json['mobile'],
      store_link: json['store_link'],
      owner_name: json['owner_name'],
      store_email: json['store_email'],
      store_contact: json['contact_number'],
      about_us: json['about_us'],
      business_since: json['business_since'],
      pincode: json['pincode'],
      from_time: json['from_time'],
      to_time: json['to_time'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class Products {
  int id;
  int store_id;
  String product_name;
  String category_id;
  String product_mrp;
  String product_price;
  String product_count;
  String product_description;
  int product_status;
  int product_id;
  String product_image;

  Products(
    this.id,
    this.store_id,
    this.product_name,
    this.category_id,
    this.product_mrp,
    this.product_price,
    this.product_count,
    this.product_description,
    this.product_status,
    this.product_id,
    this.product_image,
  );

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    store_id = json['store_id'];
    product_name = json['product_name'];
    category_id = json['category_id'];
    product_mrp = json['product_mrp'];
    product_price = json['product_price'];
    product_count = json['product_count'];
    product_description = json['product_description'];
    product_status = json['product_status'];
    product_id = json['product_id'];
    product_image = json['product_image'];
  }
}

class MyStoreDetail {
  final int id;
  final int customer_id;
  final String store_name;
  final String store_logo;
  final String store_banner;
  final String store_theme;
  final String store_category;
  final int delivery_option;
  final String store_address;
  final String store_slug;
  final int store_status;
  final int store_open;
  final int operator_id;
  final String created_at;
  final String updated_at;
  final String profile_image;
  final String first_name;
  final String last_name;
  final String mobile;
  final String store_link;
  final String owner_name;
  final String store_email;
  final String store_contact;
  final String about_us;
  final String business_since;
  final String pincode;
  final String from_time;
  final String to_time;
  final String latitude;
  final String longitude;

  MyStoreDetail({
    this.id,
    this.customer_id,
    this.store_name,
    this.store_logo,
    this.store_banner,
    this.store_theme,
    this.store_category,
    this.delivery_option,
    this.store_address,
    this.store_slug,
    this.store_status,
    this.store_open,
    this.operator_id,
    this.created_at,
    this.updated_at,
    this.profile_image,
    this.first_name,
    this.last_name,
    this.mobile,
    this.store_link,
    this.owner_name,
    this.store_email,
    this.store_contact,
    this.about_us,
    this.business_since,
    this.pincode,
    this.from_time,
    this.to_time,
    this.latitude,
    this.longitude,
  });

  factory MyStoreDetail.fromJson(json) {
    return MyStoreDetail(
      id: json['id'],
      customer_id: json['customer_id'],
      store_name: json['store_name'],
      store_logo: json['store_logo'],
      store_banner: json['store_banner'],
      store_theme: json['store_theme'],
      store_category: json['store_category'],
      delivery_option: json['delivery_option'],
      store_address: json['store_address'],
      store_slug: json['store_slug'],
      store_status: json['store_status'],
      operator_id: json['operator_id'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      profile_image: json['profile_image'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      mobile: json['mobile'],
      store_link: json['store_link'],
      store_open: json['store_open'],
      owner_name: json['owner_name'],
      store_email: json['store_email'],
      store_contact: json['store_contact'],
      about_us: json['about_us'],
      business_since: json['business_since'],
      pincode: json['pincode'],
      from_time: json['from_time'],
      to_time: json['to_time'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
