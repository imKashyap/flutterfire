import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPhonePage extends StatelessWidget {
  final User user;

  AddPhonePage(this.user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Add Phone'),
      ),
    );
  }
}
