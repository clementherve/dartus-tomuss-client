import 'package:dartus/tomuss.dart';

class ParsedPage {
  late List<Semester> _semesters;
  late List<TeachingUnit> _teachingunits;
  ParsedPage(this._semesters, this._teachingunits);
  ParsedPage.empty() {
    _semesters = [];
    _teachingunits = [];
  }

  List<TeachingUnit> get teachingunits => _teachingunits;
  List<Semester> get semesters => _semesters;
}
