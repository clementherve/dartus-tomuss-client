import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tomuss/src/authentication/authentication.dart';
import 'package:tomuss/src/constant/constants.dart';
import 'package:tomuss/src/model/semester.dart';
import 'package:tomuss/src/utils/urlmanager.dart';
import 'package:tomuss/src/model/teachingunit.dart';
import 'package:tomuss/src/parser/htmlparser.dart';

class TomussClient {
  late bool _isAuthenticated;
  late Dio _dio;
  late HTMLparser _parser;
  late Authentication _authentication;

  TomussClient() {
    _parser = HTMLparser();
    _authentication = Authentication();
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 3, followRedirects: true));
    _dio.interceptors.add(CookieManager(_authentication.cookieJar));
  }

  Future<bool> authenticate(
      final String username, final String password) async {
    _isAuthenticated = await _authentication.authenticate(username, password);
    return _isAuthenticated;
  }

  List<TeachingUnit> getTeachingUnit() {
    return _parser.extractTeachingUnits();
  }

  List<Semester> getSemesters() {
    return _parser.extractSemesters();
  }

  Future<bool> getPage(final String url) async {
    if (!_isAuthenticated) return false;

    String content = (await _request(url)).getOrElse(() => "");

    while (content.length < 1000 && content.isNotEmpty) {
      // there is a delay if you refresh tomuss too quicky
      // get the delay and wait
      final BeautifulSoup bs = BeautifulSoup(content);
      final int delay =
          int.tryParse(bs.find("#t")?.text ?? "10") ?? 10 + 1; // get #t
      await Future.delayed(
          Duration(seconds: delay)); // sleep(Duration(seconds:1));

      // then do the request again
      content = (await _request(url)).getOrElse(() => "");
    }

    _parser.parse(content);
    return true;
  }

  Future<Option<String>> _request(final String url) async {
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
    final String content = response.data;
    return (content.isNotEmpty) ? Some(content) : None();
  }

  static String currentSemester() {
    return UrlManager.currentSemester(DateTime.now());
  }

  static String previousSemester() {
    return UrlManager.previousSemester(DateTime.now());
  }
}
