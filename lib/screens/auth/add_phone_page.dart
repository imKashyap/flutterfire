import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/sevices/phone_auth_model.dart';
import 'package:provider/provider.dart';
import 'phone_login_ui.dart';

class AddPhonePage extends StatelessWidget {
  final PhoneAuthModel model;
  AddPhonePage({@required this.model});

  static Widget create(User userToLink) {
    return ChangeNotifierProvider<PhoneAuthModel>(
      create: (_) => PhoneAuthModel(
        userToLink: userToLink,
        type: PhoneAuthType.register,
      ),
      child: Consumer<PhoneAuthModel>(
        builder: (context, model, _) => AddPhonePage(
          model: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneLoginUI(model);
  }
}
