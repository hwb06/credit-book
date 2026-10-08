class StringConstant {
  StringConstant._();

  // App
  static const String appName = 'Credit Book';

  // Date formats
  static const String formatted = 'dd MMM yyyy';
  static const String formattedWithSlash = 'dd/MM/yyyy';
  static const String formattedDateTime = 'dd MMM yyyy, hh:mm a';
  static const String formattedTime = 'hh:mm a';

  // Time ago
  static const String yearsAgo = ' years ago';
  static const String monthsAgo = ' months ago';
  static const String daysAgo = ' days ago';
  static const String hoursAgo = ' hours ago';
  static const String minutesAgo = ' minutes ago';
  static const String justNow = 'Just now';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';

  static const String credit = 'credit';
  static const String payment = 'payment';

  // Settings
  static const int overdueDays = 7;
  static const String currency = 'Rs';

  // Firestore
  static const String usersCollection = 'users';
  static const String customersCollection = 'customers';
  static const String transactionsCollection = 'transactions';
}