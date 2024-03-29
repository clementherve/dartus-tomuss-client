import 'package:dartus/src/utils/roundtoprecision.dart';

class Grade {
  late String _name;
  late String _author;

  late double _gradeNumerator;
  late double _gradeDenominator;
  late int _rank;
  late double _average;
  late double _mediane;
  late bool _isValidGrade;
  late int _groupeSize;

  Grade.fromJSON(var id, var json, var stats, var line) {
    _rank = stats[json['the_id']]['rank'] ?? -1;
    _groupeSize = stats[json['the_id']]['nr'] ?? -1;
    _isValidGrade = (_rank != -1);
    if (!_isValidGrade) {
      return;
    }
    _name = json['title'] ?? "";
    _author = json['author'] ?? "";
    _average = Round.round(stats[json['the_id']]['average']);
    _mediane = Round.round(stats[json['the_id']]['mediane']);

    _gradeNumerator =
        (line.length > 0 && id < line.length - 1 && line[id].length > 0)
            ? Round.round(double.tryParse(line[id][0].toString()))
            : double.nan;

    _gradeDenominator = double.tryParse(
        (json['minmax'] ?? "").split(";").last.replaceAll("]", "") ??
                "20") ??
        20; // "minmax": "[0;22]",
  }

  String get name => _name;
  String get author => _author;
  int get rank => _rank;
  int get groupSize => _groupeSize;
  double get gradeDenominator => _gradeDenominator;
  double get average => _average;
  double get gradeNumerator => _gradeNumerator;
  double get mediane => _mediane;
  bool get isValidGrade => _isValidGrade;
  String get humanGrade => "$_gradeNumerator/$_gradeDenominator";
}
