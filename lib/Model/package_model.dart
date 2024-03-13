class GetPackages {
  int id;
  String package_name;
  int package_amount;
  int package_type;
  int package_count;
  int package_days;
  int package_status;

  GetPackages(
    this.id,
    this.package_name,
    this.package_amount,
    this.package_type,
    this.package_count,
    this.package_days,
    this.package_status,
  );

  GetPackages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    package_name = json['package_name'];
    package_amount = json['package_amount'];
    package_type = json['package_type'];
    package_count = json['package_count'];
    package_days = json['package_days'];
    package_status = json['package_status'];
  }
}
