class AdsDetail {
  final int id;
  final String customer_id;
  final String category_id;
  final String sub_category_id;
  final String service_type;
  final String ads_name;
  final String ads_description;
  final String ads_image;
  final String ads_price;
  final String city_name;
  final String door_step;
  final String city_id;
  final String type_of_service;
  final int ads_status;
  final String ads_slug;
  final String created_at;
  final String updated_at;
  final String profile_image;
  final String first_name;
  final String last_name;
  final String join_year;
  final String posted_at;
  final int ads_price_int;
  final String contact_name;
  final String contact_mobile;
  final String contact_email;
  final int ids;
  final int price_type;
  String favorite_status;
  final String ads_type;
  final String brand_name;
  final String model;
  final String registration_date;
  final String fuel_type;
  final String engine_size;
  final String transmission;
  final String km_driven;
  final String no_of_owner;
  final String seller_by;
  final String type_of_property;
  final String bedrooms_type;
  final String furnished;
  final String construction_status;
  final String listed_by;
  final String car_parking_space;
  final String facing;
  final String form_whom;
  final String super_buildup_area_sq_ft;
  final String carpet_area_sq_ft;
  final String washrooms;
  final String rent_monthly;
  final String property_type;
  final String plot_area;
  final String length;
  final String breadth;
  final String pg_sub_type;
  final String meal_included;
  final String floor;
  final String company_name;
  final String salary_period;
  final String job_type;
  final String qualification;
  final String english;
  final String experience;
  final String gender;
  final String salary_from;
  final String salary_to;
  AdsDetail({
    this.id,
    this.customer_id,
    this.category_id,
    this.sub_category_id,
    this.service_type,
    this.ads_name,
    this.ads_description,
    this.ads_image,
    this.ads_price,
    this.city_name,
    this.door_step,
    this.city_id,
    this.type_of_service,
    this.ads_status,
    this.ads_slug,
    this.created_at,
    this.updated_at,
    this.profile_image,
    this.first_name,
    this.last_name,
    this.join_year,
    this.posted_at,
    this.ads_price_int,
    this.favorite_status,
    this.contact_name,
    this.contact_mobile,
    this.contact_email,
    this.ids,
    this.price_type,
    this.ads_type,
    this.brand_name,
    this.model,
    this.registration_date,
    this.fuel_type,
    this.engine_size,
    this.transmission,
    this.km_driven,
    this.no_of_owner,
    this.seller_by,
    this.type_of_property,
    this.bedrooms_type,
    this.furnished,
    this.construction_status,
    this.listed_by,
    this.car_parking_space,
    this.facing,
    this.form_whom,
    this.super_buildup_area_sq_ft,
    this.carpet_area_sq_ft,
    this.washrooms,
    this.rent_monthly,
    this.property_type,
    this.plot_area,
    this.length,
    this.breadth,
    this.pg_sub_type,
    this.meal_included,
    this.floor,
    this.company_name,
    this.salary_period,
    this.job_type,
    this.qualification,
    this.english,
    this.experience,
    this.gender,
    this.salary_from,
    this.salary_to,
  });

  factory AdsDetail.fromJson(Map<String, dynamic> json) {
    return AdsDetail(
      id: json['id'],
      customer_id: json['customer_id'].toString(),
      category_id: json['category_id'].toString(),
      sub_category_id: json['sub_category_id'].toString(),
      service_type: json['service_type'],
      ads_name: json['ads_name'],
      ads_description: json['ads_description'],
      ads_image: json['ads_image'],
      ads_price: json['ads_price'].toString(),
      city_name: json['city_name'],
      door_step: json['door_step'],
      city_id: json['city_id'].toString(),
      type_of_service: json['type_of_service'],
      ads_status: json['ads_status'],
      ads_slug: json['ads_slug'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      profile_image: json['profile_image'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      join_year: json['join_year'],
      posted_at: json['posted_at'],
      ads_price_int: json['ads_price_int'],
      favorite_status: json['favorite_status'],
      contact_name: json['contact_name'],
      contact_mobile: json['contact_mobile'],
      contact_email: json['contact_email'],
      price_type: json['price_type'],
      ids: json['ids'],
      ads_type: json['ads_type'],
      brand_name: json['extra']['brand_name'],
      model: json['extra']['model'],
      registration_date: json['extra']['registration_date'],
      fuel_type: json['extra']['fuel_type'],
      engine_size: json['extra']['engine_size'],
      transmission: json['extra']['transmission'],
      km_driven: json['extra']['km_driven'],
      no_of_owner: json['extra']['no_of_owner'],
      seller_by: json['extra']['seller_by'],
      type_of_property: json['extra']['type_of_property'],
      bedrooms_type: json['extra']['bedrooms_type'],
      furnished: json['extra']['furnished'],
      construction_status: json['extra']['construction_status'],
      listed_by: json['extra']['listed_by'],
      car_parking_space: json['extra']['car_parking_space'],
      facing: json['extra']['facing'],
      form_whom: json['extra']['form_whom'],
      super_buildup_area_sq_ft: json['extra']['super_buildup_area_sq_ft'],
      carpet_area_sq_ft: json['extra']['carpet_area_sq_ft'],
      washrooms: json['extra']['washrooms'],
      rent_monthly: json['extra']['rent_monthly'],
      property_type: json['extra']['property_type'],
      plot_area: json['extra']['plot_area'],
      length: json['extra']['length'],
      breadth: json['extra']['breadth'],
      pg_sub_type: json['extra']['pg_sub_type'],
      meal_included: json['extra']['meal_included'],
      floor: json['extra']['floor'],
      company_name: json['extra']['company_name'],
      salary_period: json['extra']['salary_period'],
      job_type: json['extra']['job_type'],
      qualification: json['extra']['qualification'],
      english: json['extra']['english'],
      experience: json['extra']['experience'],
      gender: json['extra']['gender'],
      salary_from: json['extra']['salary_from'],
      salary_to: json['extra']['salary_to'],
    );
  }
}

class AllImage {
  String image_name;
  int id;

  AllImage(
    this.image_name,
    this.id,
  );

  AllImage.fromJson(Map<String, dynamic> json) {
    image_name = json['image_name'];
    id = json['id'];
  }
}

// class ExtraDetails {
//   final String brand_name;
//   final String model;
//   final String registration_date;
//   final String fuel_type;
//   final String engine_size;
//   final String transmission;
//   final String km_driven;
//   final String no_of_owner;
//   final String seller_by;
//   final String type_of_property;
//   final String bedrooms_type;
//   final String furnished;
//   final String construction_status;
//   final String listed_by;
//   final String car_parking_space;
//   final String facing;
//   final String form_whom;
//   final String super_buildup_area_sq_ft;
//   final String carpet_area_sq_ft;
//   final String washrooms;
//   final String rent_monthly;
//   final String property_type;
//   final String plot_area;
//   final String length;
//   final String breadth;
//   final String pg_sub_type;
//   final String meal_included;
//   final String floor;
//   final String company_name;
//   final String salary_period;
//   final String job_type;
//   final String qualification;
//   final String english;
//   final String experience;
//   final String gender;
//   final String salary_from;
//   final String salary_to;
//   ExtraDetails({
//     this.brand_name,
//     this.model,
//     this.registration_date,
//     this.fuel_type,
//     this.engine_size,
//     this.transmission,
//     this.km_driven,
//     this.no_of_owner,
//     this.seller_by,
//     this.type_of_property,
//     this.bedrooms_type,
//     this.furnished,
//     this.construction_status,
//     this.listed_by,
//     this.car_parking_space,
//     this.facing,
//     this.form_whom,
//     this.super_buildup_area_sq_ft,
//     this.carpet_area_sq_ft,
//     this.washrooms,
//     this.rent_monthly,
//     this.property_type,
//     this.plot_area,
//     this.length,
//     this.breadth,
//     this.pg_sub_type,
//     this.meal_included,
//     this.floor,
//     this.company_name,
//     this.salary_period,
//     this.job_type,
//     this.qualification,
//     this.english,
//     this.experience,
//     this.gender,
//     this.salary_from,
//     this.salary_to,
//   });

//   factory ExtraDetails.fromJson(Map<String, dynamic> json) {
//     return ExtraDetails(
//       brand_name: json['brand_name'],
//       model: json['model'],
//       registration_date: json['registration_date'],
//       fuel_type: json['fuel_type'],
//       engine_size: json['engine_size'],
//       transmission: json['transmission'],
//       km_driven: json['km_driven'],
//       no_of_owner: json['no_of_owner'],
//       seller_by: json['seller_by'],
//       type_of_property: json['type_of_property'],
//       bedrooms_type: json['bedrooms_type'],
//       furnished: json['furnished'],
//       construction_status: json['construction_status'],
//       listed_by: json['listed_by'],
//       car_parking_space: json['car_parking_space'],
//       facing: json['facing'],
//       form_whom: json['form_whom'],
//       super_buildup_area_sq_ft: json['super_buildup_area_sq_ft'],
//       carpet_area_sq_ft: json['carpet_area_sq_ft'],
//       washrooms: json['washrooms'],
//       rent_monthly: json['rent_monthly'],
//       property_type: json['property_type'],
//       plot_area: json['plot_area'],
//       length: json['length'],
//       breadth: json['breadth'],
//       pg_sub_type: json['pg_sub_type'],
//       meal_included: json['meal_included'],
//       floor: json['floor'],
//       company_name: json['company_name'],
//       salary_period: json['salary_period'],
//       job_type: json['job_type'],
//       qualification: json['qualification'],
//       english: json['english'],
//       experience: json['experience'],
//       gender: json['gender'],
//       salary_from: json['salary_from'],
//       salary_to: json['salary_to'],
//     );
//   }
// }
