import 'package:flutter/foundation.dart';
import '../constants/app_strings.dart';
import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static void debugLog(String message) {
    if (kDebugMode) debugPrint('AppDebug: $message');
  }

  static String formatCurrency(num amount) {
    final f = NumberFormat('#,##0.##');
    return '${StringConstant.currency} ${f.format(amount)}';
  }

  static String formatPhoneForWhatsApp(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) {
      digits = '92${digits.substring(1)}';
    } else if (digits.length == 10 && digits.startsWith('3')) {
      digits = '92$digits';
    }
    return digits;
  }
}
