@Timeout(Duration(seconds: 60))
import 'dart:convert';
import 'dart:io';

import 'package:dartus/tomuss.dart';
import 'package:test/test.dart';
import 'package:dartus/src/utils/urlmanager.dart';

void main() async {
  late Dartus tomuss;

  setUpAll(() {
    tomuss = Dartus();
  });

  test('Dartus.authenticate', () async {
    final String username = Platform.environment['username'] ?? "";
    final String password = Platform.environment['password'] ?? "";

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }
    final bool isAuthenticated = await tomuss.authenticate(
        username, utf8.decode(base64.decode(password)).trim());
    expect(isAuthenticated, equals(true));
  });

  test('Dartus.getPage', () async {
    final bool ok = await tomuss.getPage("https://tomuss.univ-lyon1.fr");
    expect(ok, equals(true));
  });

  test('Dartus.getPage x2', () async {
    final bool ok = await tomuss.getPage("https://tomuss.univ-lyon1.fr");
    expect(ok, equals(true));
  }, timeout: Timeout.parse("5m"));

  // TODO: check edge values
  test('Dartus.currentSemester()', () async {
    expect(UrlManager.currentSemester(DateTime.parse("20220124")),
        "https://tomuss.univ-lyon1.fr/S/2022/Printemps");

    expect(UrlManager.currentSemester(DateTime.parse("20211129")),
        "https://tomuss.univ-lyon1.fr/S/2021/Automne");

    expect(UrlManager.previousSemester(DateTime.parse("20220124")),
        "https://tomuss.univ-lyon1.fr/S/2021/Automne");

    expect(UrlManager.previousSemester(DateTime.parse("20211129")),
        "https://tomuss.univ-lyon1.fr/S/2021/Printemps");
  });
}
