import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:tomuss/src/constant/constants.dart';

class Authentication {
  late bool isAuthenticated = false;

  // TODO
  Future<bool> authenticate(
      final String username, final String passsword) async {
    return false;
  }

  Future<String> getExecToken() async {
    http.Response response = await http.get(Uri.parse(Constants.cas),
        headers: {'User-Agent': Constants.userAgent});

    if (response.statusCode >= 400) {
      throw "Failed: ${response.statusCode}";
    }

    final BeautifulSoup bs = BeautifulSoup(response.body);
    final String execToken =
        bs.find('*', attrs: {'name': 'execution'})?.attributes['value'] ?? "";
    // final Map<String, String> cookies = response.headers['cookies'] ?? {};
    return "";
  }
}
