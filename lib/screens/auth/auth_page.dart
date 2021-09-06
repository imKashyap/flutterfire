import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnect/managers/email_signin_manager.dart';
import 'package:konnect/models/email_sign_in_model.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:konnect/widgets/platform_exception_alert_dialog.dart';
import 'package:provider/provider.dart';

import 'phone_login_page.dart';

class AuthPage extends StatefulWidget {
  static const String routeName = '/auth';
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  bool _toLinkFb = false;
  String _emailToLink = '';
  AuthCredential _credsToLink;
  Dimensions myDim;
  @override
  Widget build(BuildContext context) {
    myDim = Dimensions(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundScreen(),
            Container(
              height: myDim.height * 0.70,
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
      padding: EdgeInsets.only(
        top: myDim.height * 0.01,
        right: myDim.width * 0.06,
        left: myDim.width * 0.06,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: myDim.height * 0.15,
          ),
          Image.asset(
            'assets/images/logo.png',
            scale: 11,
          ),
          Text(
            'Because anything can happen over a chat.',
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
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => kColorPrimary),
              ),
              onPressed: _isLoading ? null : () => _signInWithEmail(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Sign in Free',
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
          buildSocialLoginButton(context,
              icon: Icon(
                Icons.phone_android_outlined,
                color: Colors.white,
              ),
              text: 'Continue with phone number', onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (c) => PhoneLoginPage.create()));
          }),
          buildSocialLoginButton(context,
              icon: Image.asset(
                'assets/images/google-logo.png',
              ),
              text: 'Continue with Google',
              onPressed: () => _isLoading ? null : _signInWithGoogle()),
          buildSocialLoginButton(
            context,
            icon: Image.asset(
              'assets/images/facebook-logo.png',
              color: Color(0xFF1748BB),
            ),
            text: 'Continue with Facebook',
            onPressed: () => _isLoading ? null : _signInWithFb(),
          ),
        ],
      ),
    );
  }

  Container _buildBackgroundScreen() {
    return Container(
      height: myDim.height * 0.70,
      decoration: BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
              image: AssetImage('assets/images/login_bg.jpg'))),
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
              padding: EdgeInsets.symmetric(vertical: myDim.height * 0.015),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              child: Row(
                children: [
                  SizedBox(
                    width: myDim.width * 0.07,
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

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signInWithGoogle(_toLinkFb, _emailToLink, _credsToLink);
    } on PlatformException catch (e) {
      print('Login Error: ' + e.code);
      setState(() {
        _isLoading = false;
      });
      if (e.code != 'ERROR_ABORTED_BY_USER') showErrorDialog(e);
    }
  }

  Future<void> _signInWithFb() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signInWithFb();
    } on PlatformException catch (e) {
      print('Login Error: ' + e.code);
      if (e.code == 'ERROR_ALREADY_HAS_ACCOUNT') {
        _toLinkFb = true;
        _emailToLink = e.details['email'];
        _credsToLink = e.details['creds'];
      }
      setState(() {
        _isLoading = false;
      });
      if (e.code != 'ERROR_ABORTED_BY_USER') showErrorDialog(e);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => EmailSignInManager(
                  type: EmailSignInFormType.signIn,
                  toLink: _toLinkFb,
                  linkType: LinkType.fb,
                  previousEmail: _emailToLink,
                  creds: _credsToLink,
                )));
  }

  void showErrorDialog(PlatformException e) {
    PlatfromrExceptionAlertDialog(title: 'Sign In Failed', e: e).show(context);
  }
}
