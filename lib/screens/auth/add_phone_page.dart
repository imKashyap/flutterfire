import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:konnect/sevices/phone_auth_model.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:provider/provider.dart';
import '../../validators/form_validator.dart';
import 'otp_page.dart';

class AddPhonePage extends StatefulWidget {
  final PhoneAuthModel model;
  AddPhonePage({@required this.model});

  static Widget create(User userToLink) {
    return ChangeNotifierProvider<PhoneAuthModel>(
      create: (_) => PhoneAuthModel(
        userToLink: userToLink,
        type: PhoneAuthType.register,
      ),
      child: Consumer<PhoneAuthModel>(
        builder: (context, model, _) => AddPhonePage(
          model: model,
        ),
      ),
    );
  }

  @override
  _AddPhonePageState createState() => _AddPhonePageState();
}

class _AddPhonePageState extends State<AddPhonePage> with FormValidator {
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
      SizedBox(height: 30.0),
      Text(
        'Enter your phone number',
        textScaleFactor: myDim.textScaleFactor,
        style: Theme.of(context)
            .textTheme
            .headline6
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
      await model.verifyPhoneNumber();
    } catch (e) {
      print("error " + e.message);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => OtpPage(
          model: model,
        ),
      ),
    );
  }

  // Future<void> verifyPhoneNumber() async {
  //   PhoneVerificationCompleted verificationCompleted =
  //       (PhoneAuthCredential phoneAuthCredential) async {
  //     await widget.userToLink.linkWithCredential(phoneAuthCredential);
  //     await _auth.signInWithCredential(phoneAuthCredential);
  //     setState(() {
  //       _verified = true;
  //     });
  //     showSnackbar(
  //         "Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
  //   };
  //   PhoneVerificationFailed verificationFailed =
  //       (FirebaseAuthException authException) {
  //     showSnackbar(
  //         'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
  //   };
  //   PhoneCodeSent codeSent =
  //       (String verificationId, [int forceResendingToken]) async {
  //     showSnackbar('Please check your phone for the verification code.');
  //     _verificationId = verificationId;
  //   };
  //   PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
  //       (String verificationId) {
  //     showSnackbar("verification code: " + verificationId);
  //     _verificationId = verificationId;
  //   };
  //   try {
  //     await _auth.verifyPhoneNumber(
  //         phoneNumber: _phoneNumber,
  //         timeout: const Duration(seconds: 60),
  //         verificationCompleted: verificationCompleted,
  //         verificationFailed: verificationFailed,
  //         codeSent: codeSent,
  //         codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  //   } catch (e) {
  //     showSnackbar("Failed to Verify Phone Number: $e");
  //   }
  // }

  // Future<void> signInWithPhoneNumber() async {
  //   try {
  //     final AuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: _verificationId,
  //       smsCode: _otp,
  //     );
  //     await widget.userToLink.linkWithCredential(credential);
  //     await _auth.signInWithCredential(credential);

  //     //showSnackbar("Successfully signed in UID: ${user.uid}");
  //   } catch (e) {
  //     showSnackbar("Failed to sign in: " + e.toString());
  //   }
  // }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
