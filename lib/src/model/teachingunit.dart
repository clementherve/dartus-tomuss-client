import 'package:tomuss/src/model/grade.dart';
import 'package:tomuss/src/model/teacher.dart';
import 'package:tomuss/src/model/text.dart';

class TeachingUnit {
  String name;
  List<Teacher> masters = [];
  List<Grade> grades = [];
  List<Text> textValues = [];
  TeachingUnit(this.name, this.masters, this.grades, this.textValues);
}
