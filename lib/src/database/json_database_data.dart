class JsonDatabaseData {
  JsonDatabaseData({required this.key, required this.data});

  String key;
  Map<String, dynamic> data;

  factory JsonDatabaseData.fromJson(Map<String, dynamic> json) {
    return JsonDatabaseData(key: json['key'], data: json['data']);
  }

  Map<String, dynamic> toJson() => {'key': key, 'data': data};
}
