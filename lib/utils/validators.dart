class MyValidators {
  // Hubinta Email-ka
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email-ka lama furi karo';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Fadlan geli email sax ah (tusaale: magac@gmail.com)';
    }
    return null;
  }

  // Hubinta Password-ka
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password-ka lama furi karo';
    }
    if (value.length < 6) {
      return 'Password-ku waa inuu ka badnaadaa 6 xaraf';
    }
    return null;
  }

  // Hubinta Lambarka Taleefanka (Soomaaliya)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lambarka taleefanka waa muhiim';
    }
    if (value.length < 9) {
      return 'Lambarku waa inuu ka koobnaadaa ugu yaraan 9 lambar';
    }
    return null;
  }
}
