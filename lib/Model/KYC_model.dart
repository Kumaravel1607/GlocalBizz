class KYCDocument {
  int id;
  int store_id;
  String document_type;
  String document_name;

  KYCDocument(
    this.id,
    this.store_id,
    this.document_type,
    this.document_name,
  );

  KYCDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    store_id = json['store_id'];
    document_type = json['document_type'];
    document_name = json['document_name'];
  }
}
