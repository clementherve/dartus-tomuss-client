import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dartus/src/authentication/authentication.dart';
import 'package:dartus/src/constant/constants.dart';
import 'package:dartus/src/model/semester.dart';
import 'package:dartus/src/utils/urlmanager.dart';
import 'package:dartus/src/model/teachingunit.dart';
import 'package:dartus/src/parser/htmlparser.dart';

class Dartus {
  late bool _isAuthenticated;
  late Dio _dio;
  late HTMLparser _parser;
  late Authentication _authentication;

  Dartus() {
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

    String content = await _request(url, null);

    if (content.length < 1000) {
      final BeautifulSoup bs = BeautifulSoup(content);
      // there is a delay if you refresh tomuss too quicky
      final double delay = double.tryParse(bs.find("#t")?.text ?? "") ?? 15.0;

      return Future.delayed(Duration(seconds: delay.round() + 2), () async {
        content = await Future.sync(() => _request(url, delay));
        if (content.length > 1000) {
          _parser.parse(content);
        }
        return content.length > 1000;
      });
    }

    return content.length > 1000;
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
    return UrlManager.currentSemester(DateTime.now());
  }

  static String previousSemester() {
    return UrlManager.previousSemester(DateTime.now());
  }
}
