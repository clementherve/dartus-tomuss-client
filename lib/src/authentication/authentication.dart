// ignore_for_file: depend_on_referenced_packages

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dartus/src/constant/constants.dart';
import 'package:dartus/src/utils/parse_cookie_date.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:requests/requests.dart';

class Authentication {
  late bool _isAuthenticated = false;
  late String _username;
  late String _password;

  Authentication(final String username, final String password) {
    Requests.clearStoredCookies(Requests.getHostname(Constants.caslogin));
    _username = username;
    _password = password;
  }

  Future<bool> authenticate() async {
    _isAuthenticated = (await _shouldReconnect())
        ? await _authenticationRequest(await getExecToken())
        : _isAuthenticated;

    return _isAuthenticated;
  }

  Future<void> logout() async {
    await Requests.get("https://cas.univ-lyon1.fr/cas/logout");
  }

  Future<String> serviceRequest(final String url, {bool unsafe = true}) async {
    final Response response = await Requests.get(
      "https://cas.univ-lyon1.fr/cas/login?service=$url${(unsafe ? '/?unsafe=1' : '')}",
      headers: {
        'User-Agent': Constants.userAgent,
        'Cookie': await getCasCookies(),
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'DNT': '1', // Do Not Track, because, why not
      },
    );

    if ((response.statusCode) >= 400) {
      throw "Failed to fetch the page: ${response.statusCode}";
    }

    return response.body;
  }

  @visibleForTesting
  Future<String> getExecToken() async {
    // perform the request and check the status code
    final Response response = await Requests.get(
      Constants.caslogin,
      headers: {
        'User-Agent': Constants.userAgent,
        'Cookie': await getCasCookies()
      },
    );

    if ((response.statusCode) >= 400) {
      throw "Failed: ${response.statusCode}";
    }

    // extract the exec token from the html
    final BeautifulSoup bs = BeautifulSoup(response.body);
    final String execToken =
        bs.find('*', attrs: {'name': 'execution'})?.attributes['value'] ?? "";

    return execToken;
  }

  Future<bool> _shouldReconnect() async {
    final List<Cookie> cookies = (await Requests.getStoredCookies(
            Requests.getHostname(Constants.caslogin)))
        .values
        .toList();

    if (cookies.isEmpty) return true;
    for (final Cookie cookie in cookies) {
      if (parseCookieDate(cookie['expires'] ?? "")?.isAfter(DateTime.now()) ??
          true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _authenticationRequest(final String execToken) async {
    final Response response = await Requests.post(
      Constants.caslogin,
      body: {
        'username': _username,
        'password': _password,
        'lt': '',
        'execution': execToken,
        '_eventId': 'submit',
        'submit': 'SE+CONNECTER'
      },
      headers: {
        'User-Agent': Constants.userAgent,
        'cookie': await getCasCookies(),
        'DNT': '1', // Do Not Track, because, why not
        'Content-Type': 'application/x-www-form-urlencoded',
      },

    );

    if ((response.statusCode) >= 400) {
      return false;
    }

    final String casCookies = await getCasCookies();
    return casCookies.isNotEmpty && casCookies.contains("TGC=");
  }

  Future<String> getCasCookies() async {
    return await _getCookiesForURL(Constants.caslogin);
  }

  Future<String> _getCookiesForURL(final String url) async {
    String cookiesString = "";
    final List<Cookie> cookies =
        (await Requests.getStoredCookies(Requests.getHostname(url)))
            .values
            .toList();

    for (final Cookie cookie in cookies) {
      cookiesString += "${cookie.name}=${cookie.value}; ";
    }

    return cookiesString.length > 2
        ? cookiesString.substring(0, cookiesString.length - 2)
        : "";
  }

  bool get isAuthenticated => _isAuthenticated;
  Future<CookieJar> get cookieJar async => (await Requests.getStoredCookies(Requests.getHostname(Constants.caslogin)));
}
