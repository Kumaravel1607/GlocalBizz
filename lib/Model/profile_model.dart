class UserDetails {
  final String id;
  final String first_name;
  final String last_name;
  final String email;
  final String mobile;
  final String gender;
  final String dob;
  final String city;
  UserDetails({
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.mobile,
    this.gender,
    this.dob,
    this.city,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'].toString(),
      first_name: json['first_name'],
      last_name: json['last_name'],
      email: json['email'],
      mobile: json['mobile'],
      gender: json['gender'],
      dob: json['dob'],
      city: json['city'],
    );
  }
}
