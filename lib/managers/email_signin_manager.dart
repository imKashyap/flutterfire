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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Sign In'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
              child: EmailSignInForm.create(
                  context, toLink, previousEmail, creds)),
        ),
      ),
    );
  }
}
