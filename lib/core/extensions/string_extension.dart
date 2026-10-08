extension StringExtension on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail =>
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(trim());

  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 10 && digits.length <= 13;
  }
}
