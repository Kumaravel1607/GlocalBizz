class CurrencyModel {
  int id;
  String currency_symbol;

  CurrencyModel(
    this.id,
    this.currency_symbol,
  );

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency_symbol = json['currency_symbol'];
  }
}
