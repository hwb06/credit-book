import 'package:url_launcher/url_launcher.dart';
import 'package:udhaar_app/core/utils/app_utils.dart';

class WhatsAppUtils {
  WhatsAppUtils._();

  static String reminderMessage(String name, double balance) {
    return 'Hello $name,\n'
        'This is a friendly reminder that you have a pending balance of '
        '${AppUtils.formatCurrency(balance)} with us. '
        'Please pay it when you can.\n'
        'Thank you.';
  }

  static Uri reminderLink({
    required String phone,
    required String name,
    required double balance,
  }) {
    final number = AppUtils.formatPhoneForWhatsApp(phone);
    final text = Uri.encodeComponent(reminderMessage(name, balance));
    return Uri.parse('https://wa.me/$number?text=$text');
  }

  static Future<bool> sendReminder({
    required String phone,
    required String name,
    required double balance,
  }) {
    final uri = reminderLink(phone: phone, name: name, balance: balance);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
