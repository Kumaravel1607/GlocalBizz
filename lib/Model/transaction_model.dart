class TransactionModel {
  int id;
  String order_no;
  String package_name;
  String package_type_name;
  String status_text;
  int amount;
  int discount;
  String total_amount;
  String transcation_id;
  int payment_status;
  int package_type;

  TransactionModel(
    this.id,
    this.order_no,
    this.package_name,
    this.package_type_name,
    this.status_text,
    this.amount,
    this.discount,
    this.total_amount,
    this.transcation_id,
    this.payment_status,
    this.package_type,
  );

  TransactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order_no = json['order_no'];
    package_name = json['package_name'];
    package_type_name = json['package_type_name'];
    status_text = json['status_text'];
    amount = json['amount'];
    discount = json['discount'];
    total_amount = json['total_amount'].toString();
    transcation_id = json['transcation_id'];
    payment_status = json['payment_status'];
    package_type = json['package_type'];
  }
}
