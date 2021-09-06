import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  Stream<User> getCurrentAuthState();
  User getCurrentUser();
  Future<User> signInWithGoogle(bool toLink,
      [String previousEmail, AuthCredential creds]);
  Future<User> signUpWithEmail(String email, String password, bool toLink,
      [AuthCredential creds]);
  Future<User> loginWithEmail(String email, String password, bool toLink,
      [String previousEmail, AuthCredential creds]);
  Future<User> signInWithFb();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}

class Auth implements AuthBase {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _fbLogin = FacebookLogin();

  // Konnector _getUserFromFirebase(User user) {
  //   if (user == null) return null;
  //   return Konnector(user: user);
  // }

  @override
  Stream<User> getCurrentAuthState() {
    return _auth.authStateChanges();
  }

  @override
  User getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<User> signUpWithEmail(String email, String password, bool toLink,
      [AuthCredential creds]) async {
    try {
      UserCredential userCreds = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCreds.user.sendEmailVerification();
      if (toLink) userCreds.user.linkWithCredential(creds);
      await signOut();
      return null;
    } catch (e) {
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  Future<User> loginWithEmail(String email, String password, bool toLink,
      [String previousEmail, AuthCredential creds, String phoneNo]) async {
    try {
      UserCredential userCreds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!toLink) {
        final user = userCreds.user;
        if (user.emailVerified)
          return userCreds.user;
        else {
          Duration duration =
              user.metadata.creationTime.difference(DateTime.now());
          if (duration.inSeconds > 299) {
            await user.delete();
            throw PlatformException(
                code: 'ERROR_USER_NOT_FOUND',
                message:
                    'Your account has been deleted since lacking email verification');
          } else {
            int minutesLeft = user.metadata.creationTime
                .add(Duration(minutes: 5))
                .difference(DateTime.now())
                .inMinutes;
            throw PlatformException(
                code: 'ERROR_USER_NOT_VERIFIED',
                message:
                    'Please verify your account under $minutesLeft minutes.');
          }
        }
      }
      if (userCreds.user.email == previousEmail) {
        await userCreds.user.linkWithCredential(creds);
        return userCreds.user;
      } else
        throw PlatformException(
            code: 'ERROR_TRIED_DIFFERENT_ACCOUNT',
            message:
                'The email address from your facebook account does not match the given email address');
    } catch (e) {
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  Future<User> signInWithGoogle(bool toLink,
      [String previousEmail, AuthCredential creds]) async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final UserCredential userCreds = await _auth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken));
        if (!toLink) return userCreds.user;
        if (userCreds.user.email == previousEmail) {
          await userCreds.user.linkWithCredential(creds);
          return userCreds.user;
        } else
          throw PlatformException(
              code: 'ERROR_TRIED_DIFFERENT_ACCOUNT',
              message:
                  'Unable to link facebook account with your given email address.');
      } else
        throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKENS',
            message: 'Google auth tokens are missing');
    } else
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
  }

  @override
  Future<User> signInWithFb() async {
    final result = await _fbLogin.logIn(
      ['email', 'public_profile'],
    );
    if (result.accessToken != null) {
      try {
        final UserCredential userCreds =
            await _auth.signInWithCredential(FacebookAuthProvider.credential(
          result.accessToken.token,
        ));
        return userCreds.user;
      } catch (e) {
        if (e.code != 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL') throw e;
        final httpClient = new HttpClient();
        final graphRequest = await httpClient.getUrl(Uri.parse(
            "https://graph.facebook.com/v2.12/me?fields=email&access_token=${result.accessToken.token}"));
        final graphResponse = await graphRequest.close();
        final graphResponseJSON =
            json.decode((await graphResponse.transform(utf8.decoder).single));
        final email = graphResponseJSON["email"];
        final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
        print(signInMethods);
        bool isProviderGoogle = signInMethods.contains('google.com');
        if (isProviderGoogle)
          throw PlatformException(
              code: 'ERROR_ALREADY_HAS_ACCOUNT',
              details: {
                'email': email,
                'creds': FacebookAuthProvider.credential(
                  result.accessToken.token,
                )
              },
              message: 'Try signing in with Google');
        else
          throw PlatformException(
              code: 'ERROR_ALREADY_HAS_ACCOUNT',
              details: {
                'email': email,
                'creds': FacebookAuthProvider.credential(
                  result.accessToken.token,
                )
              },
              message: 'Try signing in with Email & Password');
      }
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }

  @override
  Future<void> signOut() async {
    await _fbLogin.logOut();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw PlatformException(code: e.code, message: e.message);
    }
  }
}
