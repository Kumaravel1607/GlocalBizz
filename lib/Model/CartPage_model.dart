class MyCartList {
  int id;
  int customer_id;
  int store_id;
  int product_id;
  int quantity;
  int price;
  String product_image;
  String product_name;
  int product_price;
  int delivery_fee;

  MyCartList(
    this.id,
    this.customer_id,
    this.store_id,
    this.product_id,
    this.quantity,
    this.price,
    this.product_image,
    this.product_name,
    this.product_price,
    this.delivery_fee,
  );

  MyCartList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customer_id = json['customer_id'];
    store_id = json['store_id'];
    product_id = json['product_id'];
    quantity = json['quantity'];
    price = json['price'];
    product_image = json['product_image'];
    product_name = json['product_name'];
    product_price = json['product_price'];
    delivery_fee = json['delivery_fee'];
  }
}

class ItemData {
  final int id;
  final int customer_id;
  final int store_id;
  final int product_id;
  int quantity;
  final int price;
  final String product_image;
  final String product_name;
  ItemData({
    this.id,
    this.customer_id,
    this.store_id,
    this.product_id,
    this.quantity,
    this.price,
    this.product_image,
    this.product_name,
  });
}
