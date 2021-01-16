import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';



abstract class AuthBase {
  Stream<User> getCurrentAuthState();
  //Future<User> getCurrentUser();
  Future<User> signInAnonymously();
  Future<User> signInWithGoogle();
  Future<User> signUpWithEmail(String email, String password);
  Future<User> loginWithEmail(String email, String password);
  Future<User> signInWithFb();
  Future<void> signOut();
  Future<void> convertUserWithEmail(String email, String password, String name);
  Future<void> converWithGoogle();
  Future<void> updateUserName(String name, FirebaseUser currentUser);
  Future<void> sendPasswordResetEmail(String email);
}

class Auth implements AuthBase {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _fbLogin = FacebookLogin();

  User _getUserFromFirebase(FirebaseUser user) {
    if (user == null) return null;
    return User(uid: user.uid);
  }

  @override
  Stream<User> getCurrentAuthState() {
    return _auth.onAuthStateChanged.map((user) => _getUserFromFirebase(user));
  }

  // @override
  // Future<User> getCurrentUser() async {
  //   FirebaseUser user = await _auth.currentUser();
  //   return _getUserFromFirebase(user);
  // }

  @override
  Future<User> signInAnonymously() async {
    AuthResult authResult = await _auth.signInAnonymously();
    return _getUserFromFirebase(authResult.user);
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    // Update the username
    //await updateUserName(name, authResult.user);
    return _getUserFromFirebase(authResult.user);
  }

  @override
  Future<User> loginWithEmail(String email, String password) async {
    AuthResult authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _getUserFromFirebase(authResult.user);
  }

  @override
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthResult authResult = await _auth.signInWithCredential(
            GoogleAuthProvider.getCredential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken));
        return _getUserFromFirebase(authResult.user);
      } else {
        throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKENS',
            message: 'Google auth tokens are missing');
      }
    } else {
      throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
    }
  }

  @override
  Future<User> signInWithFb() async {
    final result = await _fbLogin.logIn(
      ['public_profile'],
    );
    if (result.accessToken != null) {
      final AuthResult authResult =
          await _auth.signInWithCredential(FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      ));
      return _getUserFromFirebase(authResult.user);
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
  Future<void> convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = await _auth.currentUser();

    final credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(name, currentUser);
  }

  @override
  Future<void> converWithGoogle() async {
    final currentUser = await _auth.currentUser();
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    await currentUser.linkWithCredential(credential);
    await updateUserName(_googleSignIn.currentUser.displayName, currentUser);
  }

  @override
  Future<void> updateUserName(String name, FirebaseUser currentUser) async {
    var userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await currentUser.updateProfile(userUpdateInfo);
    await currentUser.reload();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
