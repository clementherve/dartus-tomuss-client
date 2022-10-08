import 'package:test/test.dart';
import 'package:dartus/src/authentication/authentication.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  late Authentication authOK;
  DotEnv env = DotEnv(includePlatformEnvironment: true);
  setUp(() {
    env.load();
    final String username = env['USERNAME'] ?? "";
    final String password = env['PASSWORD'] ?? "";

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }

    authOK = Authentication(username, password);
  });

  test('getExecToken', () async {
    expect(await authOK.getExecToken(), isNotEmpty);
  });

  test('authenticate.ok', () async {
    final bool isAuthenticated = await authOK.authenticate();
    final String cookies = await authOK.getCasCookies();
    expect(isAuthenticated, equals(true));
    expect(cookies, contains("TGC="));
  });

  test('authenticate.fail', () async {
    Authentication authBAD = Authentication("p1234567", "not_valid_password");
    final bool isAuthenticated = await authBAD.authenticate();

    final String cookies = await authOK.getCasCookies();

    expect(isAuthenticated, equals(false));
    expect(cookies, isNot(contains("TGC=")));
  });
}
