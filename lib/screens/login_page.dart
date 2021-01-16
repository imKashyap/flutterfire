import 'package:flutter/material.dart';
import 'package:konnect/utils/colors.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 450.0,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.contain,
                      image: AssetImage('assets/images/bg_login.jpg'))),
            ),
            Container(
              height: 450.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 100.0,
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    scale: 11,
                  ),
                  Text(
                    'Let those words fly\n to people you want.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.transparent)),
                      onPressed: () {},
                      child: Text(
                        'Sign up Free',
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      color: kColorPrimary,
                    ),
                  ),
                  buildSocialLoginButton(context,
                      icon: Icon(
                        Icons.phone_android_outlined,
                        color: Colors.white,
                      ),
                      text: 'Continue with phone number',
                      onPressed: () {}),
                  buildSocialLoginButton(context,
                      icon: Image.asset(
                        'assets/images/google-logo.png',
                      ),
                      text: 'Continue with Google',
                      onPressed: () {}),
                  buildSocialLoginButton(context,
                      icon: Image.asset(
                        'assets/images/facebook-logo.png',
                        color: Color(0xFF1748BB),
                      ),
                      text: 'Continue with Facebook',
                      onPressed: () {}),
                  buildSocialLoginButton(context,
                      icon: null, text: 'Log in', onPressed: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSocialLoginButton(BuildContext context,
      {@required Widget icon,
      @required String text,
      @required Function onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: icon == null
          ? Text(
              text,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    color: Colors.white,
                  ),
            )
          : Row(
              children: [
                const SizedBox(
                  width: 30.0,
                ),
                Container(width: 23.0, height: 23.0, child: icon),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
