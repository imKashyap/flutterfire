import 'package:flutter/material.dart';
import 'package:konnect/utils/colors.dart';

class LoginPage extends StatelessWidget {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundScreen(),
            Container(
              height: 450.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
            ),
            _buildInteractionScreen(context),
            _isLoading
                ? Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                    color: Colors.black54,
                    child: Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kColorPrimary),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Padding _buildInteractionScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
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
            'Let those words fly\n to your people on Konnect.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Container(
            width: double.infinity,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.transparent)),
              onPressed: () {
                print('Pressed');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Sign up Free',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
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
              text: 'Continue with phone number', onPressed: () {
            print('Pressed');
          }),
          buildSocialLoginButton(context,
              icon: Image.asset(
                'assets/images/google-logo.png',
              ),
              text: 'Continue with Google', onPressed: () {
            print('Pressed');
          }),
          buildSocialLoginButton(context,
              icon: Image.asset(
                'assets/images/facebook-logo.png',
                color: Color(0xFF1748BB),
              ),
              text: 'Continue with Facebook', onPressed: () {
            print('Pressed');
          }),
          buildSocialLoginButton(context, icon: null, text: 'Log in',
              onPressed: () {
            print('Pressed');
          }),
        ],
      ),
    );
  }

  Container _buildBackgroundScreen() {
    return Container(
      height: 450.0,
      decoration: BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.topCenter,
              fit: BoxFit.contain,
              image: AssetImage('assets/images/bg_login.jpg'))),
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
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              child: Row(
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
            ),
    );
  }
}
