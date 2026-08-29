class AppConstants {
  static const int localVideosLimit = 30;
  static const int accountnumber = 123_456_789;
  static const String whatsappNumber = "+249912212622";

  // Plan Codes
  static const String planBasic = 'basicbook';
  static const String planFirstBook = 'firstbook_advance';
  static const String planSecondBook = 'secondbook_advance';

  // Plan Names (Arabic)
  static const Map<String, String> planNames = {
    planBasic: ' الرياضيات الأساسية',
    planFirstBook: 'متخصصة الكتاب الأول',
    planSecondBook: 'متخصصة الكتاب الثاني',
  };

  static String getPlanName(String code) => planNames[code] ?? code;
}
