class ChatList {
  int id;
  String ads_id;
  String sender_id;
  String receiver_id;
  String message;
  String created_at;
  String updated_at;
  String ads_name;
  String ads_image;
  String display_name;
  String display_time;
  int unread_count;
  int ads_status;

  ChatList(
    this.id,
    this.ads_id,
    this.sender_id,
    this.receiver_id,
    this.message,
    this.created_at,
    this.updated_at,
    this.ads_name,
    this.ads_image,
    this.display_name,
    this.display_time,
    this.unread_count,
    this.ads_status,
  );

  ChatList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ads_id = json['ads_id'].toString();
    sender_id = json['sender_id'].toString();
    receiver_id = json['receiver_id'].toString();
    message = json['message'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
    ads_name = json['ads_name'];
    ads_image = json['ads_image'];
    display_name = json['display_name'];
    display_time = json['display_time'];
    unread_count = json['unread_count'];
    ads_status = json['ads_status'];
  }
}

class ChatAdsDetail {
  final int id;
  final String ads_name;
  final String ads_image;
  final String ads_price;
  final String service_type;
  final String from_id;
  final String to_id;
  ChatAdsDetail({
    this.id,
    this.ads_name,
    this.ads_image,
    this.ads_price,
    this.service_type,
    this.from_id,
    this.to_id,
  });

  factory ChatAdsDetail.fromJson(Map<String, dynamic> json) {
    return ChatAdsDetail(
      id: json['id'],
      ads_name: json['ads_name'],
      ads_image: json['ads_image'],
      ads_price: json['ads_price'].toString(),
      service_type: json['service_type'],
      from_id: json['from_id'].toString(),
      to_id: json['to_id'].toString(),
    );
  }
}

class ChatHistory {
  int id;
  String ads_id;
  String sender_id;
  String receiver_id;
  String message;
  String created_at;
  String updated_at;

  ChatHistory(
    this.id,
    this.ads_id,
    this.sender_id,
    this.receiver_id,
    this.message,
    this.created_at,
    this.updated_at,
  );

  ChatHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ads_id = json['ads_id'].toString();
    sender_id = json['sender_id'].toString();
    receiver_id = json['receiver_id'].toString();
    message = json['message'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];
  }
}
