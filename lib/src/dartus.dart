import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dartus/src/parser/parsedpage.dart';
import 'package:dartz/dartz.dart';
import 'package:dartus/src/authentication/authentication.dart';
import 'package:dartus/src/utils/urlcreator.dart';
import 'package:dartus/src/parser/htmlparser.dart';

class Dartus {
  final Authentication _authentication;

  const Dartus(this._authentication);


  Authentication get authentication => _authentication;

  Future<bool> authenticate() async {
    return await _authentication.authenticate();
  }

  Future<Option<ParsedPage>> getParsedPage(final String url) async {
    if (!_authentication.isAuthenticated) return None();

    String content = await _authentication.serviceRequest(url);
    final HTMLparser parser = HTMLparser();

    if (content.length < 1000) {
      final BeautifulSoup bs = BeautifulSoup(content);
      // there is a delay if you refresh tomuss too quicky
      final double delay = double.tryParse(bs.find("#t")?.text ?? "") ?? 15.0;

      return Future.delayed(Duration(seconds: delay.round() + 2), () async {
        content = await Future.sync(() => _authentication.serviceRequest(url));
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

  static String currentSemester() {
    return URLCreator.currentSemester(DateTime.now());
  }

  static String previousSemester() {
    return URLCreator.previousSemester(DateTime.now());
  }
}
