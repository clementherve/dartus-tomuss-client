import 'package:tomuss/src/utils/stringcasing.dart';

class Teacher {
  late String name;
  late String email;
  Teacher(this.name, this.email);
  Teacher.fromJSON(var json) {
    name = "${Capitalize.to(json[0])} ${json[1] ?? ''}"; // Firstname LASTNAME
    email = json[2] ?? ""; // firstname.lastname@domain.ext
  }
}
