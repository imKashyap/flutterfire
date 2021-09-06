import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/models/email_sign_in_model.dart';
import 'package:konnect/screens/auth/email_sign_in_form.dart';

class EmailSignInManager extends StatelessWidget {
  final bool toLink;
  final String previousEmail;
  final AuthCredential creds;
  final EmailSignInFormType type;
  final  LinkType linkType;

  const EmailSignInManager({
    this.toLink,
    this.previousEmail,
    this.creds,
    @required this.linkType,
    @required this.type,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: EmailSignInForm.create(
          context,
          toLink,
          previousEmail,
          creds,
          type,
          linkType,
        ),
      ),
    );
  }
}
