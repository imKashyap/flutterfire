import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class Konnector with ChangeNotifier {
  User user;
  String gender;
  bool isRegistered;

  Konnector({
    this.user,
    this.gender = '',
    this.isRegistered = false,
  });

  void updateWith({
    User user,
    String gender,
    bool isRegistered,
  }) {
    this.user = user ?? this.user;
    this.gender = gender ?? this.gender;
    this.isRegistered = isRegistered ?? this.isRegistered;
    notifyListeners();
  }

  void updateAuthData(User user) => updateWith(user: user);

  void updatePhoneNumber(User user) => updateWith(user: user);
  void updateRegisterData({User user, String gender, bool isRegistered}) => updateWith(
        user: user,
        gender: gender,
        isRegistered: isRegistered
      );
}
