import 'dart:convert';
import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:tomuss/src/model/grade.dart';
import 'package:tomuss/src/model/semester.dart';
import 'package:tomuss/src/model/teacher.dart';
import 'package:tomuss/src/model/teachingunit.dart';
import 'package:tomuss/src/model/text.dart';

class HTMLparser {
  late dynamic json;

  HTMLparser();

  HTMLparser.toJSON(final String rawContent) {
    parse(rawContent);
  }

  void parse(final String rawContent) {
    final String jsonReady = toJSONready(extractContent(rawContent)) ?? "[]";
    json = jsonDecode(jsonReady);
  }

  @visibleForTesting
  String? extractContent(final String rawContent) {
    final RegExp regExp = RegExp("display_update\\((.*?),\"Top\"");
    final RegExpMatch? match = regExp.firstMatch(rawContent);
    return match?.group(1);
  }

  @visibleForTesting
  String? toJSONready(String? extractedContent) {
    extractedContent = extractedContent?.replaceAll("\\x3E", ">") ?? "";
    return extractedContent.replaceAll("NaN", "-1");
  }

  @visibleForTesting
  int? getIndexForKey(final String name) {
    int i = 0;
    for (var key in json) {
      if (key[0] == name) return i;
      i++;
    }
    return null;
  }

  List<TeachingUnit> extractTeachingUnits() {
    final int? key = getIndexForKey('Grades');
    if (key == null) return [];

    final List<TeachingUnit> units = [];
    for (var unit in json[key][1][0]) {
      final line = unit['line']; // grade value
      final stats = unit['stats']; // grade statistics: rank, mediane, average
      final columns = unit['columns']; // grade name

      final List<Teacher> masters = [];
      unit['masters'].forEach((item) => {masters.add(Teacher.fromJSON(item))});

      final List<Grade> grades = [];
      final List<Text> texts = [];
      int id = 0;
      columns.forEach((item) {
        if (item['type']
            .toString()
            .contains(RegExp('note|moy|cow', caseSensitive: false))) {
          final Grade grade = Grade.fromJSON(id, item, stats, line);
          (grade.isValidGrade) ? grades.add(grade) : null;
        } else {
          final Text text = Text.fromJSON(id, item, line);
          (text.isValidText) ? texts.add(text) : null;
        }
        id++;
      });

      units
          .add(TeachingUnit(unit['table_title'] ?? "", masters, grades, texts));
    }
    return units;
  }

  List<Semester> extractSemesters() {
    final int? key = getIndexForKey('Semesters');
    if (key == null) return [];

    final List<Semester> semesters = [];
    for (var item in json[key][1].keys) {
      semesters.add(Semester(item, json[key][1][item]));
    }
    return semesters;
  }
}
