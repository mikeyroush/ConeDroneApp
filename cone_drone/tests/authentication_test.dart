import 'package:flutter_test/flutter_test.dart';
import 'package:cone_drone/services/auth.dart';

void main() {
  setUp(() {});
  tearDown(() {});

  test('Empty email returns error string', () {
    var result = AuthService.validateEmail('');
    expect(result, 'Enter an Email');
  });

  test('Non-empty email returns null', () {
    var result = AuthService.validateEmail('email');
    expect(result, null);
  });

  test('Empty password returns error string', () {
    var result = AuthService.validatePassword('');
    expect(result, 'Enter a password of 6+ characters');
  });

  test('Password of 6+ chars returns null', () {
    var result = AuthService.validatePassword('password');
    expect(result, null);
  });
}
