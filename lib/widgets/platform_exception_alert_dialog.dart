import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:konnect/widgets/platform_alert_dialog.dart';

class PlatfromrExceptionAlertDialog extends PlatformAlertDialog {
  PlatfromrExceptionAlertDialog(
      {@required String title, @required PlatformException e})
      : super(
          title: title,
          defaultActionText: 'OK',
          content: _message(e),
        );

  static String _message(PlatformException e) {
    return _errorMessage[e.code] ?? e.message;
  }

  static Map<String, String> _errorMessage = {
    'ERROR_INVALID_EMAIL': 'The email address is malformed',
    'ERROR_WRONG_PASSWORD': 'The password is wrong.',
    'ERROR_USER_NOT_FOUND':
        'There is no user corresponding to the given email address, or The user has been deleted.',
    'ERROR_USER_DISABLED': 'The user has been disabled ',
    'ERROR_TOO_MANY_REQUESTS':
        'There was too many attempts to sign in as this user.',
    'ERROR_OPERATION_NOT_ALLOWED': 'Email & Password accounts are not enabled.',
    'ERROR_WEAK_PASSWORD': 'The password is not strong enough',
    'ERROR_EMAIL_ALREADY_IN_USE':
        'The email is already in use by a different account.',
  };
}
