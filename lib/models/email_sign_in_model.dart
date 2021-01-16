import 'package:flutter/cupertino.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/validators/form_validator.dart';

enum EmailSignInFormType { signIn, signUp }

class EmailSignInModel with FormValidator,ChangeNotifier {
  String email;
  String password;
  bool isLoading;
  EmailSignInFormType formType;
  bool isSubmitted;
  final AuthBase auth;

  EmailSignInModel({
    @required this.auth,
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.isSubmitted = false,
  });

  void toggleFormType() {
    final formType = this.formType == EmailSignInFormType.signIn
        ? EmailSignInFormType.signUp
        : EmailSignInFormType.signIn;
    updateWith(
      email: '',
      password: '',
      formType: formType,
      isLoading: false,
      isSubmitted: false,
    );
  }

  Future<void> submit() async {
    updateWith(isSubmitted: true, isLoading: true);
    try {
      if (formType == EmailSignInFormType.signIn) {
        await auth.loginWithEmail(email, password);
      } else {
        await auth.signUpWithEmail(email, password);
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }
  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);
  
  void updateWith(
      {String email,
      String password,
      EmailSignInFormType formType,
      bool isLoading,
      bool isSubmitted}) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.isSubmitted = isSubmitted ?? this.isSubmitted;
    notifyListeners();
  }

  String get primaryButtonText {
    return formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
  }

  String get secondaryButtonText {
    return formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';
  }

  bool get canSubmit {
    return emailValidator.isValid(email) &&
        passValidator.isValid(password) &&
        !isLoading;
  }

  String get passErrorText {
    bool showErrorText = isSubmitted && !passValidator.isValid(password);
    return showErrorText ? passError : null;
  }

  String get emailErrorText {
    bool showErrorText = isSubmitted && !emailValidator.isValid(email);
    return showErrorText ? emailError : null;
  }
}
