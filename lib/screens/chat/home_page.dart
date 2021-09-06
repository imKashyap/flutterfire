import 'package:flutter/material.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Homepage',
          ),
          ElevatedButton(
            onPressed: () async {
              await auth.signOut();
            },
            child: Text('Sign Out'),
          )
        ],
      ),
    );
  }
}
