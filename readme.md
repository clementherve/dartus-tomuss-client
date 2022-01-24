# 🚧 Tomuss Dart
This package allows you to login and fetch teaching units from Tomuss (https://tomuss.univ-lyon1.fr).

## Example
```dart
final Tomuss tomuss = Tomuss();
final bool isAuthenticated =
    await tomuss.authenticate("p1234567", "a_valid_password");

if (isAuthenticated) {
    final List<TeachingUnit> teachingUnits =
        (await tomuss.getPage(Tomuss.currentSemester(DateTime.now())))
            .getTeachingUnit();

    // list teaching units
    for (final TeachingUnit tu in teachingUnits) {
        print(tu.name);
        print("\tGrades:");
        for (final Grade g in tu.grades) {
        print("\t\t${g.name}: ${g.gradeNumerator}/${g.gradeDenominator}");
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
```