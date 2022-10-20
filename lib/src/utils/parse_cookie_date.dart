DateTime? parseCookieDate(String date) {
  const List monthsLowerCase = [
    "jan",
    "feb",
    "mar",
    "apr",
    "may",
    "jun",
    "jul",
    "aug",
    "sep",
    "oct",
    "nov",
    "dec"
  ];

  int position = 0;

  // Never error() {
  //
  //   throw HttpException("Invalid cookie date $date");
  // }

  bool isEnd() => position == date.length;

  bool isDelimiter(String s) {
    int char = s.codeUnitAt(0);
    if (char == 0x09) return true;
    if (char >= 0x20 && char <= 0x2F) return true;
    if (char >= 0x3B && char <= 0x40) return true;
    if (char >= 0x5B && char <= 0x60) return true;
    if (char >= 0x7B && char <= 0x7E) return true;
    return false;
  }

  bool isNonDelimiter(String s) {
    int char = s.codeUnitAt(0);
    if (char >= 0x00 && char <= 0x08) return true;
    if (char >= 0x0A && char <= 0x1F) return true;
    if (char >= 0x30 && char <= 0x39) return true; // Digit
    if (char == 0x3A) return true; // ':'
    if (char >= 0x41 && char <= 0x5A) return true; // Alpha
    if (char >= 0x61 && char <= 0x7A) return true; // Alpha
    if (char >= 0x7F && char <= 0xFF) return true; // Alpha
    return false;
  }

  bool isDigit(String s) {
    int char = s.codeUnitAt(0);
    if (char > 0x2F && char < 0x3A) return true;
    return false;
  }

  int getMonth(String month) {
    if (month.length < 3) return -1;
    return monthsLowerCase.indexOf(month.substring(0, 3));
  }

  int toInt(String s) {
    int index = 0;
    for (; index < s.length && isDigit(s[index]); index++) {}
    return int.parse(s.substring(0, index));
  }

  var tokens = <String>[];
  while (!isEnd()) {
    while (!isEnd() && isDelimiter(date[position])) {
      position++;
    }
    int start = position;
    while (!isEnd() && isNonDelimiter(date[position])) {
      position++;
    }
    tokens.add(date.substring(start, position).toLowerCase());
    while (!isEnd() && isDelimiter(date[position])) {
      position++;
    }
  }

  String? timeStr;
  String? dayOfMonthStr;
  String? monthStr;
  String? yearStr;

  for (var token in tokens) {
    if (token.isEmpty) continue;
    if (timeStr == null &&
        token.length >= 5 &&
        isDigit(token[0]) &&
        (token[1] == ":" || (isDigit(token[1]) && token[2] == ":"))) {
      timeStr = token;
    } else if (dayOfMonthStr == null && isDigit(token[0])) {
      dayOfMonthStr = token;
    } else if (monthStr == null && getMonth(token) >= 0) {
      monthStr = token;
    } else if (yearStr == null &&
        token.length >= 2 &&
        isDigit(token[0]) &&
        isDigit(token[1])) {
      yearStr = token;
    }
  }

  if (timeStr == null ||
      dayOfMonthStr == null ||
      monthStr == null ||
      yearStr == null) {
    return null;
  }

  int year = toInt(yearStr);
  if (year >= 70 && year <= 99) {
    year += 1900;
  } else if (year >= 0 && year <= 69) {
    year += 2000;
  }
  if (year < 1601) return null;

  int dayOfMonth = toInt(dayOfMonthStr);
  if (dayOfMonth < 1 || dayOfMonth > 31) return null;

  int month = getMonth(monthStr) + 1;

  var timeList = timeStr.split(":");
  if (timeList.length != 3) return null;
  int hour = toInt(timeList[0]);
  int minute = toInt(timeList[1]);
  int second = toInt(timeList[2]);
  if (hour > 23) return null;
  if (minute > 59) return null;
  if (second > 59) return null;

  return DateTime.utc(year, month, dayOfMonth, hour, minute, second, 0);
}
