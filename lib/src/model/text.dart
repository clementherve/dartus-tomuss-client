class Text {
  late String _name;
  late String _value;
  late String _author;
  late String _comment;
  late bool _isValidText;

  Text.fromJSON(dynamic id, dynamic json, dynamic line) {
    _name = json['title'] ?? "";
    _author = json['author'] ?? "";
    _comment = json['comment'] ?? "";

    _value = (line.length > 0 && id < line.length - 1 && line[id].length > 0)
        ? line[id][0].toString()
        : "";
    _isValidText = _value.isNotEmpty;
  }

  String get name => _name;
  String get value => _value;
  String get author => _author;
  String get comment => _comment;
  bool get isValidText => _isValidText;
}
