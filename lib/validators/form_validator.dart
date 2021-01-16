abstract class StringValidator {
  bool isValid(String value);
}

class ValidEmail implements StringValidator {
  @override
  bool isValid(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }
}

class ValidPassword implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length > 5;
  }
}

class ValidPhoneNo implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length == 10 && int.tryParse(value) != null;
  }
}

class ValidOtp implements StringValidator {
  @override
  bool isValid(String value) {
    return value.length == 6 && int.tryParse(value) != null;
  }
}
class FormValidator {
  final StringValidator emailValidator = ValidEmail();
  final StringValidator passValidator = ValidPassword();
  final StringValidator phoneValidator = ValidPhoneNo();
  final StringValidator otpValidator = ValidOtp();
  final String emailError = 'Enter a valid email.';
  final String passError = 'Enter atleast 6 characters password.';
  final String phoneError = 'Enter a valid phone number.';
  final String otpError = 'Enter a valid 6 digit otp.';
}
