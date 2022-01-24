# 🚧 Tomuss Dart
This package allows you to login and fetch teaching units from Tomuss (https://tomuss.univ-lyon1.fr).

## Example
```dart
final Tomuss tomuss = Tomuss();
final bool isAuthenticated = await tomuss.authenticate("p1234567", "a_valid_password");
if (!isAuthenticated) {
    // handle gracefully
}

// you can fetch and parse the page for the current semester
await tomuss.getPage(Tomuss.currentSemester());

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

```