import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http; // TODO: migrate to dio
import 'package:tomuss/src/model/semester.dart';
import 'package:tomuss/src/utils/urlmanager.dart';
import 'package:tomuss/src/model/teachingunit.dart';
import 'package:tomuss/src/parser/htmlparser.dart';

class TomussClient {
  late bool isAuthenticated;
  late HTMLparser _parser;

  TomussClient() {
    _parser = HTMLparser();
  }

  Future<bool> authenticate(
      final String username, final String password) async {
    // perform the login
    isAuthenticated = false;
    return isAuthenticated;
  }

  List<TeachingUnit> getTeachingUnit() {
    return _parser.extractTeachingUnits();
  }

  List<Semester> getSemesters() {
    return _parser.extractSemesters();
  }

  Future<TomussClient> getPage(final String url) async {
    String content = await _request(url);
    while (content.length < 1000) {
      // there is a delay if you refresh tomuss too quicky
      // get the delay and wait
      final BeautifulSoup bs = BeautifulSoup(content);
      final int delay =
          int.tryParse(bs.find("#t")?.text ?? "10") ?? 10 + 1; // get #t
      await Future.delayed(
          Duration(seconds: delay)); // sleep(Duration(seconds:1));

      // then do the request again
      content = await _request(url);
    }
    _parser.parse(content);
    return this;
  }

  Future<String> _request(final String url) async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode >= 400) {
      throw "Failed to fetch the page: ${response.statusCode}";
    }

    return response.body;
  }

  static String currentSemester() {
    return UrlManager.currentSemester(DateTime.now());
  }

  static String previousSemester() {
    return UrlManager.previousSemester(DateTime.now());
  }
}
