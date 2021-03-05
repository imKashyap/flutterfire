import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/screens/auth/email_sign_in_form.dart';

class EmailSignInManager extends StatelessWidget {
  final bool toLink;
  final String previousEmail;
  final AuthCredential creds;

  const EmailSignInManager({this.toLink, this.previousEmail, this.creds});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView(
        child: EmailSignInForm.create(context, toLink, previousEmail, creds),
      ),
    );
  }
}
