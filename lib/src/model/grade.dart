import 'package:tomuss/src/utils/roundtoprecision.dart';

class Grade {
  late String name;
  late String author;

  late double gradeNumerator;
  late int gradeDenominator;
  late int rank;
  late double average;
  late double mediane;
  late bool isValidGrade;

  Grade.fromJSON(var id, var json, var stats, var line) {
    rank = stats[json['the_id']]['rank'] ?? -1;
    isValidGrade = (rank != -1);
    if (!isValidGrade) {
      return;
    }
    name = json['title'] ?? "";
    author = json['author'] ?? "";
    average = Round.round(stats[json['the_id']]['average']);
    mediane = Round.round(stats[json['the_id']]['mediane']);

    gradeNumerator =
        (line.length > 0 && id < line.length - 1 && line[id].length > 0)
            ? Round.round(double.tryParse(line[id][0].toString()))
            : double.nan;

    gradeDenominator = int.tryParse(
            RegExp(';([0-9]*)\\]').firstMatch(json['minmax'] ?? "")?.group(1) ??
                "20") ??
        20; // "minmax": "[0;22]",
  }
}
