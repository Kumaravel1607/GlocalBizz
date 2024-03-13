class Location {
  final String id;
  final String city_name;

  Location({
    this.id,
    this.city_name,
  });

  factory Location.fromJson(Map<String, dynamic> parsedJson) {
    return Location(
      id: parsedJson['id'].toString(),
      city_name: parsedJson['city_name'],
    );
  }
}
