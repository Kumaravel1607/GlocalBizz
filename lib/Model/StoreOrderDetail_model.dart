class OrderedProductModel {
  int id;
  int orderId;
  int productId;
  String productName;
  String productImage;
  int productQuantity;
  int productPrice;

  OrderedProductModel(
      {this.id,
      this.orderId,
      this.productId,
      this.productName,
      this.productImage,
      this.productQuantity,
      this.productPrice});

  OrderedProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    productId = json['product_id'];
    productName = json['product_name'];
    productImage = json['product_image'];
    productQuantity = json['product_quantity'];
    productPrice = json['product_price'];
  }
}

class OrdersDetailModel {
  int id;
  String orderNo;
  int customerId;
  int storeId;
  int ordersStatus;
  String amount;
  String discount;
  int totalAmount;
  String transcationId;
  int paymentMethod;
  int paymentStatus;
  String paymentResponse;
  int orderReadStatus;
  String createdAt;
  String updatedAt;

  OrdersDetailModel(
      {this.id,
      this.orderNo,
      this.customerId,
      this.storeId,
      this.ordersStatus,
      this.amount,
      this.discount,
      this.totalAmount,
      this.transcationId,
      this.paymentMethod,
      this.paymentStatus,
      this.paymentResponse,
      this.orderReadStatus,
      this.createdAt,
      this.updatedAt});

  factory OrdersDetailModel.fromJson(Map<String, dynamic> json) {
    return OrdersDetailModel(
      id: json['id'],
      orderNo: json['order_no'],
      customerId: json['customer_id'],
      storeId: json['store_id'],
      ordersStatus: json['orders_status'],
      amount: json['amount'],
      discount: json['discount'],
      totalAmount: json['total_amount'],
      transcationId: json['transcation_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      paymentResponse: json['payment_response'],
      orderReadStatus: json['order_read_status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class DeliveryAddressModel {
  int id;
  int orderId;
  String firstName;
  String lastName;
  String mobileNo;
  String email;
  String address1;
  String address2;
  String city;
  String state;
  String country;
  String pincode;
  String landmark;
  String updateAt;

  DeliveryAddressModel(
      {this.id,
      this.orderId,
      this.firstName,
      this.lastName,
      this.mobileNo,
      this.email,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.country,
      this.pincode,
      this.landmark,
      this.updateAt});

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'],
      orderId: json['order_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      mobileNo: json['mobile_no'],
      email: json['email'],
      address1: json['address1'],
      address2: json['address2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      landmark: json['landmark'],
      updateAt: json['update_at'],
    );
  }
}
