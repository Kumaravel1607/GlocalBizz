class PaymentsModel {
  int id;
  int storeId;
  int customerId;
  int paidAmount;
  String fromDate;
  String toDate;
  String paidDate;
  int paymentStatus;
  String createdAt;
  String updatedAt;

  PaymentsModel(
      {this.id,
      this.storeId,
      this.customerId,
      this.paidAmount,
      this.fromDate,
      this.toDate,
      this.paidDate,
      this.paymentStatus,
      this.createdAt,
      this.updatedAt});

  PaymentsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    customerId = json['customer_id'];
    paidAmount = json['paid_amount'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    paidDate = json['paid_date'];
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
