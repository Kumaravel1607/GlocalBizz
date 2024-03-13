class StoreOrderModel {
  int id;
  String orderNo;
  int customerId;
  int storeId;
  int ordersStatus;
  int amount;
  String discount;
  int totalAmount;
  String transcationId;
  int paymentStatus;
  String paymentResponse;
  int orderReadStatus;
  String createdAt;
  String updatedAt;
  String ordersStatusText;
  String paymentStatusText;
  int payment_method;

  StoreOrderModel(
      {this.id,
      this.orderNo,
      this.customerId,
      this.storeId,
      this.ordersStatus,
      this.amount,
      this.discount,
      this.totalAmount,
      this.transcationId,
      this.paymentStatus,
      this.paymentResponse,
      this.orderReadStatus,
      this.createdAt,
      this.updatedAt,
      this.ordersStatusText,
      this.paymentStatusText,
      this.payment_method});

  StoreOrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNo = json['order_no'];
    customerId = json['customer_id'];
    storeId = json['store_id'];
    ordersStatus = json['orders_status'];
    amount = json['amount'];
    discount = json['discount'];
    totalAmount = json['total_amount'];
    transcationId = json['transcation_id'];
    paymentStatus = json['payment_status'];
    paymentResponse = json['payment_response'];
    orderReadStatus = json['order_read_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    ordersStatusText = json['orders_status_text'];
    paymentStatusText = json['payment_status_text'];
    payment_method = json['payment_method'];
  }
}
