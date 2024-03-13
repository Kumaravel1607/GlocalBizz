class OrderTrackModel {
  int id;
  int orderId;
  int orderStage;
  String orderDescription;
  int orderDeliveryStatus;
  String createdAt;
  String updatedAt;
  String orderDeliveryStatusText;

  OrderTrackModel(
      {this.id,
      this.orderId,
      this.orderStage,
      this.orderDescription,
      this.orderDeliveryStatus,
      this.createdAt,
      this.updatedAt,
      this.orderDeliveryStatusText});

  OrderTrackModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    orderStage = json['order_stage'];
    orderDescription = json['order_description'];
    orderDeliveryStatus = json['order_delivery_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    orderDeliveryStatusText = json['order_delivery_status_text'];
  }
}
