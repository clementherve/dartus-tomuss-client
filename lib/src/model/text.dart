class Text {
  late String name;
  late String value;
  late String author;
  late String comment;
  late bool isValidText;

  Text.fromJSON(var id, var json, var line) {
    name = json['title'] ?? "";
    author = json['author'] ?? "";
    comment = json['comment'] ?? "";

    value = (line.length > 0 && id < line.length - 1 && line[id].length > 0)
        ? line[id][0].toString()
        : "";
    isValidText = value.isNotEmpty;
  }
}
