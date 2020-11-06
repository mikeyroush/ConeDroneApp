class FormValidator {
  static final String nameMessage = 'Please enter a name.';
  static final String emailMessage = 'Please enter an email.';
  static final String emailPattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  static final RegExp emailReg = RegExp(emailPattern);
  static final String passwordMessage =
      'Please enter a password of 8+ characters.';
  static final String phoneMessage = 'Please enter a phone number.';
  static final String phonePattern = r'^(?:[+0]1)?[0-9()\s-]{10,15}$';
  static final RegExp phoneReg = new RegExp(phonePattern);

  static String validateName(String value) {
    return value.isEmpty ? nameMessage : null;
  }

  static String validateEmail(String value) {
    return !emailReg.hasMatch(value) ? emailMessage : null;
  }

  static String validatePassword(String value) {
    return value.length < 8 ? passwordMessage : null;
  }

  static String validatePhone(String value) {
    return !phoneReg.hasMatch(value) ? phoneMessage : null;
  }
}
