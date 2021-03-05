import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/screens/auth/add_phone_page.dart';
import 'package:konnect/screens/auth/auth_page.dart';
import 'package:konnect/screens/chat/home_page.dart';
import 'package:konnect/screens/loading_page.dart';
import 'package:konnect/screens/register/register_page.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthBase auth = Provider.of<AuthBase>(context);
    return StreamBuilder<User>(
      stream: auth.getCurrentAuthState(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User thisUser = snapshot.data;
          if (thisUser != null) {
            int index = thisUser.providerData
                .indexWhere((info) => info.providerId == 'password');
            if (index > -1 && !thisUser.emailVerified)
              return AuthPage();
            else {
              if (thisUser.phoneNumber == null || thisUser.phoneNumber.isEmpty)
                return AddPhonePage.create(snapshot.data);
              else {
                return FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (BuildContext context,
                        AsyncSnapshot<SharedPreferences> prefs) {
                      if (prefs.connectionState == ConnectionState.done) {
                        if (prefs.data.getBool('isRegistered') != null)
                          return HomePage();
                        else
                          return RegisterPage(snapshot.data);
                      } else
                        return LoadingPage();
                    });
              }
            }
          } else
            return AuthPage();
        } else
          return LoadingPage();
      },
    );
  }
}
