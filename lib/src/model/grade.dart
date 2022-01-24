class Grade {
  late String name = "";
  late String author = "";

  late double gradeNumerator = -1.0;
  late int gradeDenominator = 20;
  late int rank = -1;
  late double average = -1.0;
  late double mediane = -1.0;
  late bool isGrade = true;

  Grade.fromJSON(var id, var json, var stats, var line) {
    rank = stats[json['the_id']]['rank'] ?? -1;
    isGrade = (rank != -1);
    if (!isGrade) {
      return;
    }
    name = json['title'] ?? "";
    author = json['author'] ?? "";
    average = stats[json['the_id']]['average'].roundToDouble();
    mediane = stats[json['the_id']]['mediane'].roundToDouble();

    if (line.length > 0 && id < line.length - 1 && line[id].length > 0) {
      gradeNumerator =
          double.tryParse(line[id][0].toString())?.roundToDouble() ??
              double.nan;
    } else {
      gradeNumerator = double.nan;
    }

    gradeDenominator = int.tryParse(
            RegExp(';([0-9]*)\\]').firstMatch(json['minmax'] ?? "")?.group(1) ??
                "20") ??
        20; // "minmax": "[0;22]",
  }
}
