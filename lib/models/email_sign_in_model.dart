import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/validators/form_validator.dart';

enum EmailSignInFormType { signIn, signUp }
enum LinkType { phone, fb }

class EmailSignInModel with FormValidator, ChangeNotifier {
  String email;
  String password;
  bool isLoading;
  EmailSignInFormType formType;
  bool isSubmitted;
  bool toLink;
  final String previousEmail;
  final AuthCredential creds;
  final AuthBase auth;
  LinkType linkType;

  EmailSignInModel({
    @required this.linkType,
    @required this.auth,
    @required this.creds,
    @required this.formType,
    @required this.previousEmail,
    @required this.toLink,
    this.email = '',
    this.password = '',
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
        await auth.loginWithEmail(
            email, password, toLink, previousEmail, creds);
      } else {
        await auth.signUpWithEmail(email, password, toLink, creds);
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> resetPass() async {
    updateWith(isSubmitted: true, isLoading: true);
    try {
      await auth.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    } finally {
      updateWith(isSubmitted: false, isLoading: false);
    }
  }

  void updateLinkingStatus() {
    if (this.linkType == LinkType.phone &&
        this.formType == EmailSignInFormType.signIn) updateWith(toLink: false);
  }

  bool toPop() {
    return formType == EmailSignInFormType.signIn;
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);

  void updateWith(
      {String email,
      String password,
      EmailSignInFormType formType,
      bool toLink,
      bool isLoading,
      bool isSubmitted}) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.isSubmitted = isSubmitted ?? this.isSubmitted;
    this.toLink = toLink ?? this.toLink;
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

  String get primaryWelcomeText {
    return formType == EmailSignInFormType.signIn
        ? 'Welcome back!'
        : 'Hi there!';
  }

  String get secondaryWelcomeText {
    return formType == EmailSignInFormType.signIn
        ? 'Sign in to your account'
        : 'Sign up for an account';
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
