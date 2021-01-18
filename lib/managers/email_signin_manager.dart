import 'package:flutter/material.dart';
import 'package:konnect/screens/auth/email_sign_in_form.dart';

class EmailSignInManager extends StatelessWidget {
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
          child: Card(child: EmailSignInForm.create(context)),
        ),
      ),
    );
  }
}
