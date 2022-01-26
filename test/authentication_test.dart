import 'package:test/test.dart';
import 'package:dartus/src/authentication/authentication.dart';
import 'package:dotenv/dotenv.dart' show load, env;

void main() async {
  late Authentication _authOK;

  setUp(() {
    load('test/.env');

    final String username = env['username'] ?? "";
    final String password = env['password'] ?? "";

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }

    _authOK = Authentication(username, password);
  });

  test('getExecToken', () async {
    expect(await _authOK.getExecToken(), isNotEmpty);
  });

  test('authenticate.ok', () async {
    final bool isAuthenticated = await _authOK.authenticate();
    final String cookies = await _authOK.getCasCookies();
    expect(isAuthenticated, equals(true));
    expect(cookies, contains("TGC="));
  });

  test('authenticate.fail', () async {
    Authentication authBAD = Authentication("p1234567", "not_valid_password");
    final bool isAuthenticated = await authBAD.authenticate();

    final String cookies = await _authOK.getCasCookies();

    expect(isAuthenticated, equals(false));
    expect(cookies, isNot(contains("TGC=")));
  });
}
