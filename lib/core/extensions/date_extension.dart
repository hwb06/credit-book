import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

extension DateExtension on DateTime {
  String get formatted => DateFormat(StringConstant.formatted).format(this);

  String get formattedWithSlash =>
      DateFormat(StringConstant.formattedWithSlash).format(this);

  String get formattedDateTime =>
      DateFormat(StringConstant.formattedDateTime).format(this);

  String get formattedTime =>
      DateFormat(StringConstant.formattedTime).format(this);

  String get timeAgo {
    final difference = DateTime.now().difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}${StringConstant.yearsAgo}';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}${StringConstant.monthsAgo}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}${StringConstant.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${StringConstant.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${StringConstant.minutesAgo}';
    }
    return StringConstant.justNow;
  }

  bool get isToday => isSameDay(DateTime.now());

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);

  int get daysSince => DateTime.now().difference(this).inDays;

  DateTime addDays(int days) => add(Duration(days: days));

  DateTime subtractDays(int days) => subtract(Duration(days: days));
}
