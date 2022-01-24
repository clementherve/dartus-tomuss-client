import 'package:dartus/src/model/grade.dart';
import 'package:dartus/src/model/teacher.dart';
import 'package:dartus/src/model/text.dart';

class TeachingUnit {
  final String _name;
  final List<Teacher> _masters;
  final List<Grade> _grades;
  final List<Text> _textValues;
  TeachingUnit(this._name, this._masters, this._grades, this._textValues);

  String get name => _name;
  List<Teacher> get masters => _masters;
  List<Grade> get grades => _grades;
  List<Text> get textValues => _textValues;
}
