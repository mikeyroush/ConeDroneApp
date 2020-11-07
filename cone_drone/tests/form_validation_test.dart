import 'package:flutter_test/flutter_test.dart';
import 'package:cone_drone/services/form_validator.dart';

void main() {
  setUp(() {});
  tearDown(() {});

  test('Empty email returns error string', () {
    var result = FormValidator.validateEmail('');
    expect(result, FormValidator.emailMessage);
  });

  test('Invalid email returns error string', () {
    var result = FormValidator.validateEmail('email');
    expect(result, FormValidator.emailMessage);
  });

  test('Valid email returns null', () {
    var result = FormValidator.validateEmail('junk@mikeyroush.com');
    expect(result, null);
  });

  test('Empty password returns error string', () {
    var result = FormValidator.validatePassword('');
    expect(result, FormValidator.passwordMessage);
  });

  test('Password of 6+ chars returns null', () {
    var result = FormValidator.validatePassword('password');
    expect(result, null);
  });

  test('Empty name returns error string', () {
    var result = FormValidator.validateName('');
    expect(result, FormValidator.nameMessage);
  });

  test('Non-empty name returns null', () {
    var result = FormValidator.validateName('name');
    expect(result, null);
  });

  test('Empty phone number returns error string', () {
    var result = FormValidator.validatePhone('');
    expect(result, FormValidator.phoneMessage);
  });

  test('Invalid phone number returns error string', () {
    var result = FormValidator.validatePhone('979-test');
    expect(result, FormValidator.phoneMessage);
  });

  test('Valid phone number returns null', () {
    var result = FormValidator.validatePhone('+1 (979) 458-7447');
    expect(result, null);
  });

  test('Null dropdown item returns error string', () {
    var result = FormValidator.validateDropdown(null);
    expect(result, FormValidator.dropdownMessage);
  });

  test('Valid dropdown item returns null', () {
    var result = FormValidator.validateDropdown('pilot');
    expect(result, null);
  });

  test('Non-numeric string returns error string', () {
    var result = FormValidator.validateInteger('value');
    expect(result, FormValidator.integerMessage);
  });

  test('Double string returns error string', () {
    var result = FormValidator.validateInteger('0.1');
    expect(result, FormValidator.integerMessage);
  });

  test('Numeric string returns null', () {
    var result = FormValidator.validateInteger('10');
    expect(result, null);
  });
}
