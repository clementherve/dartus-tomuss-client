import 'package:dartus/src/utils/stringcasing.dart';

class Teacher {
  late String _name;
  late String _email;
  Teacher.fromJSON(var json) {
    _name = "${Capitalize.to(json[0])} ${json[1] ?? ''}"; // Firstname LASTNAME
    _email = json[2] ?? ""; // firstname.lastname@domain.ext
  }

  String get name => _name;
  String get email => _email;
}
