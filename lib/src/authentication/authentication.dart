import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:tomuss/src/constant/constants.dart';
import 'package:meta/meta.dart';

class Authentication {
  late bool isAuthenticated = false;
  late CookieJar cookieJar;
  late Dio dio;

  Authentication() {
    cookieJar = CookieJar();
    dio = Dio(BaseOptions(connectTimeout: 1000 * 3, followRedirects: true));
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<bool> authenticate(
      final String username, final String password) async {
    isAuthenticated = (await shouldReconnect())
        ? await authenticationRequest(await getExecToken(), username, password)
        : isAuthenticated;

    return isAuthenticated;
  }

  @visibleForTesting
  Future<String> getExecToken() async {
    // perform the request and check the status code
    final Response response = await dio.get(Constants.caslogin,
        options: Options(headers: {'User-Agent': Constants.userAgent}));

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
        await cookieJar.loadForRequest(Uri.parse(Constants.caslogin));

    if (cookies.isEmpty) return true;

    for (final Cookie cookie in cookies) {
      if (cookie.expires?.isAfter(DateTime.now()) ?? true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> authenticationRequest(final String execToken,
      final String username, final String password) async {
    final Cookie cookie = (await getConnectionCookies()).first;

    final Response response = await dio.post(Constants.caslogin,
        data: {
          'username': username,
          'password': password,
          'lt': '',
          'execution': execToken,
          '_eventId': 'submit',
          'submit': 'SE+CONNECTER'
        },
        options: Options(method: 'POST', followRedirects: true, headers: {
          'User-Agent': Constants.userAgent,
          'cookie':
              "${cookie.name}=${cookie.value}; tarteaucitron=!addthis=true",
          'DNT': '1',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Referer': Constants.caslogin
        }));

    if ((response.statusCode ?? 400) >= 400) {
      return false;
    }

    return (await getConnectionCookies()).isNotEmpty &&
        (await getConnectionCookies()).last.name == "TGC";
  }

  Future<List<Cookie>> getConnectionCookies() async {
    return cookieJar.loadForRequest(Uri.parse(Constants.caslogin));
  }
}
