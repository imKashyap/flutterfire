import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../validators/form_validator.dart';

enum PhoneAuthType { login, register }

class PhoneAuthModel with FormValidator, ChangeNotifier {
  String phoneNo;
  String otp;
  String verId;
  User userToLink;
  PhoneAuthType type;
  static FirebaseAuth auth = FirebaseAuth.instance;

  PhoneAuthModel({
    @required this.type,
    @required this.userToLink,
    this.phoneNo = '',
    this.otp = '',
  });

  void updateWith(
      {String phoneNo, String otp, PhoneAuthType formType, bool isSubmitted}) {
    this.phoneNo = phoneNo ?? this.phoneNo;
    this.otp = otp ?? this.otp;
    this.type = formType ?? this.type;
    notifyListeners();
  }

  void updatePhone(String phNo) => updateWith(phoneNo: phNo);

  void updateOtp(String otp) => updateWith(otp: otp);

  bool get canSubmit {
    return phoneValidator.isValid(phoneNo);
  }

  bool get isValidOtp => otpValidator.isValid(otp);

  String get phoneErrorText {
    bool showErrorText = !phoneValidator.isValid(phoneNo);
    return showErrorText ? phoneError : null;
  }

  Future<User> verifyPhoneNumber() async {
    PhoneVerificationCompleted verificationCompleted =
        type == PhoneAuthType.login
            ? (PhoneAuthCredential phoneAuthCredential) async {
                UserCredential userCreds =
                    await auth.signInWithCredential(phoneAuthCredential);
                print(
                    "Phone number automatically verified and user signed in: ${auth.currentUser.uid}");
                int index = userCreds.user.providerData
                    .indexWhere((info) => info.providerId == 'password');
                return index == -1 ? userCreds.user : null;
              }
            : (PhoneAuthCredential phoneAuthCredential) async {
                await userToLink.linkWithCredential(phoneAuthCredential);
                await auth.signInWithCredential(phoneAuthCredential);
                print(
                    "Phone number automatically verified and user signed in: ${auth.currentUser.uid}");
              };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      throw PlatformException(
          code: authException.code, message: authException.message);
    };
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      print('Please check your phone for the verification code.');
      verId = verificationId;
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("verification code: " + verificationId);
      verId = verificationId;
    };
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      return null;
    } catch (e) {
      print("Failed to Verify Phone Number: $e");
      rethrow;
    }
  }

  Future<User> signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otp,
      );
      if (type == PhoneAuthType.login) {
        UserCredential userCreds = await auth.signInWithCredential(credential);
        int index = userCreds.user.providerData
            .indexWhere((info) => info.providerId == 'password');
        return index == -1 ? userCreds.user : null;
      } else {
        await userToLink.linkWithCredential(credential);
        return null;
      }
    } catch (e) {
      print("Failed to sign in: " + e.toString());
      rethrow;
    }
  }
}
