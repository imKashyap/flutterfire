import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:konnect/managers/email_signin_manager.dart';
import 'package:konnect/models/email_sign_in_model.dart';
import 'package:konnect/screens/chat/home_page.dart';
import 'package:konnect/screens/register/register_page.dart';
import 'package:konnect/models/phone_auth_model.dart';
import 'package:konnect/widgets/platform_alert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import 'otp_page_ui.dart';

class PhoneLoginUI extends StatefulWidget {
  final PhoneAuthModel model;
  const PhoneLoginUI(this.model);
  @override
  _PhoneLOginUIState createState() => _PhoneLOginUIState();
}

class _PhoneLOginUIState extends State<PhoneLoginUI> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Dimensions myDim;
  PhoneAuthModel get model => widget.model;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    myDim = Dimensions(context);
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: myDim.width * 0.04, vertical: myDim.height * 0.01),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildChildren()),
          ),
        ));
  }

  List<Widget> _buildChildren() {
    return [
      model.type == PhoneAuthType.login
          ? _welcomeText()
          : SizedBox(height: 30.0),
      Text(
        'Enter your phone number',
        textScaleFactor: myDim.textScaleFactor,
        style: Theme.of(context)
            .textTheme
            .subtitle2
            .copyWith(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10.0),
      _buildPhoneField(),
      SizedBox(height: 20),
      _buildInfoText(),
      _isLoading
          ? Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kColorPrimary),
                  strokeWidth: 2.0,
                ),
                height: 25.0,
                width: 25.0,
              ),
            )
          : ElevatedButton(
              onPressed: model.canSubmit ? _submit : null,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) => kColorPrimary)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Continue'),
              ),
            ),
    ];
  }

  Column _welcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10.0),
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headline5.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height: 3.0,
        ),
        Text(
          'Sign in to your account',
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 30.0),
      ],
    );
  }

  Container _buildPhoneField() {
    return Container(
      height: myDim.height * 0.06,
      child: InternationalPhoneInput(
        onPhoneNumberChange: (String number,
            String internationalizedPhoneNumber, String isoCode) {
          setState(() {
            model.updatePhone(internationalizedPhoneNumber);
          });
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade900),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kColorPrimary),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
        ),
        initialSelection: '+91',
      ),
    );
  }

  Widget _buildInfoText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        'A 6-digit code will be sent by SMS to confirm your phone number.',
        textAlign: TextAlign.center,
        style:
            Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey),
      ),
    );
  }

  void _submit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      AuthCredential creds = await model.verifyPhoneNumber();
      if (creds != null)
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => EmailSignInManager(
                      linkType: LinkType.phone,
                      type: EmailSignInFormType.signUp,
                      toLink: true,
                      creds: creds,
                    )),
            ModalRoute.withName('\main'));
      else {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // if (prefs.getString('user') != null)
        //   Navigator.of(context).pushAndRemoveUntil(
        //       MaterialPageRoute(builder: (context) => HomePage()),
        //       ModalRoute.withName('\main'));
        // else
        //   Navigator.of(context).pushAndRemoveUntil(
        //       MaterialPageRoute(
        //           builder: (context) => RegisterPage(model.userToLink)),
        //       ModalRoute.withName('\main'));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => OtpPageUI(
              model: model,
            ),
          ),
        );
      }
    } on PlatformException catch (e) {
      PlatformAlertDialog(
        title: 'Failed to verify Phone number',
        content: e.message,
        defaultActionText: 'OK',
      ).show(context);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
