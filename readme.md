# Dartus: a Dart Tomuss Client
This package allows you to login and fetch teaching units from Tomuss (https://tomuss.univ-lyon1.fr).

## Example
```dart
final Dartus tomuss = Dartus("p1234567", "a_valid_password");
if (!await tomuss.authenticate()) {
    // handle gracefully
}

final Option<ParsedPage> parsedPageOpt = await tomuss.getParsedPage(Dartus.currentSemester());

if (parsedPageOpt.isNone()) {
    // handle gracefully
}

final ParsedPage parsedPage = parsedPageOpt.getOrElse(() => ParsedPage.empty());

// list teaching units
for (final TeachingUnit tu in parsedPage.teachingunits) {
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
for (final Semester s in parsedPage.semesters) {
    print("${s.name} (${s.url})");
}

```
