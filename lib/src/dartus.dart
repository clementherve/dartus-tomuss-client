import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dartus/src/parser/parsedpage.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dartus/src/authentication/authentication.dart';
import 'package:dartus/src/constant/constants.dart';
import 'package:dartus/src/utils/urlcreator.dart';
import 'package:dartus/src/parser/htmlparser.dart';

class Dartus {
  late Dio _dio;
  late Authentication _authentication;

  Dartus(final String username, final String password) {
    _authentication = Authentication(username, password);
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 3, followRedirects: true));
    _dio.interceptors.add(CookieManager(_authentication.cookieJar));
  }

  Future<bool> authenticate() async {
    return await _authentication.authenticate();
  }

  Future<Option<ParsedPage>> getParsedPage(final String url) async {
    if (!_authentication.isAuthenticated) return None();

    String content = await _request(url, null);
    final HTMLparser parser = HTMLparser();

    if (content.length < 1000) {
      final BeautifulSoup bs = BeautifulSoup(content);
      // there is a delay if you refresh tomuss too quicky
      final double delay = double.tryParse(bs.find("#t")?.text ?? "") ?? 15.0;

      return Future.delayed(Duration(seconds: delay.round() + 2), () async {
        content = await Future.sync(() => _request(url, delay));
        if (content.length > 1000) {
          parser.parse(content);
          return Some(ParsedPage(
              parser.extractSemesters(), parser.extractTeachingUnits()));
        } else {
          return None();
        }
      });
    }

    parser.parse(content);

    return Some(
        ParsedPage(parser.extractSemesters(), parser.extractTeachingUnits()));
  }

  Future<void> logout() async {
    _authentication.logout();
  }

  Future<String> _request(final String url, double? wait) async {
    final Response response = await _dio.get(
        "https://cas.univ-lyon1.fr/cas/login?service=$url/?unsafe=1",
        options: Options(headers: {
          'User-Agent': Constants.userAgent,
          'Cookie': await _authentication.getCasCookies(),
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'DNT': '1', // Do Not Track, because, why not
        }, maxRedirects: 5));

    if ((response.statusCode ?? 400) >= 400) {
      throw "Failed to fetch the page: ${response.statusCode}";
    }

    return response.data ?? "";
  }

  static String currentSemester() {
    return URLCreator.currentSemester(DateTime.now());
  }

  static String previousSemester() {
    return URLCreator.previousSemester(DateTime.now());
  }
}
