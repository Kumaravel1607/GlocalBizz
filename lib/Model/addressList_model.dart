class AddressModel {
  int id;
  int customerId;
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
  int addressType;
  String createdAt;
  String updatedAt;

  AddressModel(
      {this.id,
      this.customerId,
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
      this.addressType,
      this.createdAt,
      this.updatedAt});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobileNo = json['mobile_no'];
    email = json['email'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    pincode = json['pincode'];
    landmark = json['landmark'];
    addressType = json['address_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
