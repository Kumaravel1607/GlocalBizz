class NotificationList {
  String id;
  String customer_id;
  String notification_type;
  String notification_title;
  String notification_description;
  String created_at;
  String updated_at;

  NotificationList(
    this.id,
    this.customer_id,
    this.notification_type,
    this.notification_title,
    this.notification_description,
    this.created_at,
    this.updated_at,
  );

  NotificationList.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    customer_id = json['customer_id'].toString();
    notification_type = json['notification_type'].toString();
    notification_title = json['notification_title'];
    notification_description = json['notification_description'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}