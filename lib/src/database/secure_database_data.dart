class SecureDatabaseData {
  SecureDatabaseData({required this.key, required this.value});

  String key;
  String value;

  factory SecureDatabaseData.fromJson(Map<String, dynamic> json) {
    return SecureDatabaseData(key: json['key'], value: json['value']);
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}
