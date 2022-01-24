import 'package:dartus/tomuss.dart';

void main() async {
  final Dartus tomuss = Dartus();
  final bool isAuthenticated =
      await tomuss.authenticate("p1234567", "a_valid_password");
  if (!isAuthenticated) {
    print("You are not authenticated. Please check your username and password");
    return;
  }

  final bool ok = await tomuss.getPage(Dartus.currentSemester());

  if (!ok) {
    print("There was an error while fetching Tomuss");
    return;
  }

  // list teaching units
  for (final TeachingUnit tu in tomuss.getTeachingUnit()) {
    print(tu.name);
    print("\tGrades:");
    for (final Grade g in tu.grades) {
      print("\t\t${g.name}: ${g.humanGrade}");
    }

    // list masters for current TU
    print("\tMasters:");
    for (final Teacher t in tu.masters) {
      print("\t\t${t.name} (${t.email})");
    }
  }

  // list semesters
  for (final Semester s in tomuss.getSemesters()) {
    print("${s.name} (${s.url})");
  }
}
