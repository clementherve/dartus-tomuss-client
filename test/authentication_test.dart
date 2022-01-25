import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:dartus/src/authentication/authentication.dart';

void main() async {
  late Authentication _auth;
  setUp(() {
    _auth = Authentication();
  });

  test('getExecToken', () async {
    expect(await _auth.getExecToken(), isNotEmpty);
  });

  test('authenticate.ok', () async {
    final String username = Platform.environment['username'] ?? "";
    final String password = Platform.environment['password'] ?? "";

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }

    final bool isAuthenticated = await _auth.authenticate(
        username, utf8.decode(base64.decode(password)).trim());

    final String cookies = await _auth.getCasCookies();

    expect(isAuthenticated, equals(true));
    expect(cookies, contains("TGC="));
  });

  test('authenticate.fail', () async {
    final bool isAuthenticated =
        await _auth.authenticate("p1234567", "not_valid_password");

    final String cookies = await _auth.getCasCookies();

    expect(isAuthenticated, equals(false));
    expect(cookies, isNot(contains("TGC=")));
  });
}
