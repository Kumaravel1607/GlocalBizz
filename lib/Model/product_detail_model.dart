class ProductDetail {
  final int id;
  final String store_id;
  final String product_name;
  final String category_id;
  final String product_mrp;
  final String product_price;
  final String product_count;
  final String product_description;
  final String product_status;
  final int product_id;
  final String product_image;
  final String product_code;
  ProductDetail({
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
    this.product_code,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      store_id: json['store_id'].toString(),
      category_id: json['category_id'].toString(),
      product_name: json['product_name'].toString(),
      product_mrp: json['product_mrp'],
      product_price: json['product_price'],
      product_count: json['product_count'],
      product_description: json['product_description'],
      product_status: json['product_status'].toString(),
      product_id: json['product_id'],
      product_image: json['product_image'],
      product_code: json['product_code'].toString(),
    );
  }
}

class AllProductImage {
  String product_image;
  int id;
  int product_id;
  AllProductImage(
    this.product_image,
    this.id,
    this.product_id,
  );

  AllProductImage.fromJson(Map<String, dynamic> json) {
    product_image = json['product_image'];
    id = json['id'];
    product_id = json['product_id'];
  }
}
