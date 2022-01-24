import 'dart:io';
import 'dart:developer';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tomuss/src/constant/constants.dart';
import 'package:meta/meta.dart';

class Authentication {
  late bool _isAuthenticated = false;
  late CookieJar _cookieJar;
  late Dio _dio;

  Authentication() {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(connectTimeout: 1000 * 3, followRedirects: true));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<bool> authenticate(
      final String username, final String password) async {
    _isAuthenticated = (await shouldReconnect())
        ? await authenticationRequest(await getExecToken(), username, password)
        : _isAuthenticated;

    return _isAuthenticated;
  }

  Future<String?> getCookiesForService(final String service) async {
    final Response response =
        await _dio.get(Constants.caslogin + "?service=$service/?unsafe=1",
            options: Options(followRedirects: true, maxRedirects: 5, headers: {
              'User-Agent': Constants.userAgent,
              'cookie': await getCasCookies(),
              'DNT': '1',
            }));

    if ((response.statusCode ?? 400) >= 400) {
      return null;
    }

    return await getCookiesForURL(Constants.caslogin + "?service=$service");
  }

  @visibleForTesting
  Future<String> getExecToken() async {
    // perform the request and check the status code
    final Response response = await _dio.get(Constants.caslogin,
        options: Options(headers: {
          'User-Agent': Constants.userAgent,
          'Cookie': await getCasCookies()
        }));

    if ((response.statusCode ?? 400) >= 400) {
      throw "Failed: ${response.statusCode}";
    }

    // extract the exec token from the html
    final BeautifulSoup bs = BeautifulSoup(response.data);
    final String execToken =
        bs.find('*', attrs: {'name': 'execution'})?.attributes['value'] ?? "";

    return execToken;
  }

  @visibleForTesting
  Future<bool> shouldReconnect() async {
    final List<Cookie> cookies =
        await _cookieJar.loadForRequest(Uri.parse(Constants.caslogin));

    if (cookies.isEmpty) return true;

    for (final Cookie cookie in cookies) {
      if (cookie.expires?.isAfter(DateTime.now()) ?? true) {
        return true;
      }
    }
    return false;
  }

  @visibleForTesting
  Future<bool> authenticationRequest(final String execToken,
      final String username, final String password) async {
    final Response response = await _dio.post(Constants.caslogin,
        data: {
          'username': username,
          'password': password,
          'lt': '',
          'execution': execToken,
          '_eventId': 'submit',
          'submit': 'SE+CONNECTER'
        },
        options: Options(method: 'POST', maxRedirects: 5, headers: {
          'User-Agent': Constants.userAgent,
          'cookie': await getCasCookies(),
          'DNT': '1', // Do Not Track, because, why not
          'Content-Type': 'application/x-www-form-urlencoded',
        }));

    if ((response.statusCode ?? 400) >= 400) {
      return false;
    }

    final String casCookies = await getCasCookies();
    return casCookies.isNotEmpty && casCookies.contains("TGC=");
  }

  Future<String> getCasCookies() async {
    return await getCookiesForURL(Constants.caslogin);
  }

  @visibleForTesting
  Future<String> getCookiesForURL(final String url) async {
    String cookiesString = "";
    final List<Cookie> cookies =
        await _cookieJar.loadForRequest(Uri.parse(url));

    for (final Cookie cookie in cookies) {
      cookiesString += "${cookie.name}=${cookie.value}; ";
    }

    return cookiesString.length > 2
        ? cookiesString.substring(0, cookiesString.length - 2)
        : "";
  }

  bool get isAuthenticated => _isAuthenticated;
  CookieJar get cookieJar => _cookieJar;
}
