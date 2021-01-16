import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/screens/add_phone_page.dart';
import 'package:konnect/screens/auth_page.dart';
import 'package:konnect/screens/loading_page.dart';
import 'package:konnect/screens/register_page.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:provider/provider.dart';


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
              if (thisUser.phoneNumber == null)
                return AddPhonePage(thisUser,);
              else
                return RegisterPage();
            }
          } else
            return AuthPage();
        } else
          return LoadingPage();
      },
    );
  }
}
