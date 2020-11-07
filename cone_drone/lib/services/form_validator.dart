import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FormValidator {
  static final String nameMessage = 'Enter a name.';
  static final String emailMessage = 'Enter an email.';
  static final String emailPattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
  static final RegExp emailReg = RegExp(emailPattern);
  static final String passwordMessage = 'Enter a password of 8+ characters.';
  static final String phoneMessage = 'Enter a phone number.';
  static final String phonePattern = r'^(?:[+0]1)?[0-9()\s-]{10,15}$';
  static final RegExp phoneReg = new RegExp(phonePattern);
  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  static final String dropdownMessage = 'Select a pilot.';
  static final String integerMessage = 'Enter an integer.';

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

  static String validateDropdown(String value) {
    return value == null ? dropdownMessage : null;
  }

  static String validateInteger(String value) {
    return value == null ||
            value.isEmpty ||
            int.parse(value, onError: (e) => null) == null
        ? integerMessage
        : null;
  }
}
