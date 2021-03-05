import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';

class AddPhonePage extends StatefulWidget {
  final User userToLink;

  AddPhonePage(this.userToLink);

  @override
  _AddPhonePageState createState() => _AddPhonePageState();
}

class _AddPhonePageState extends State<AddPhonePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _smsController = TextEditingController();
  String _verificationId;
  Dimensions myDim;
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
              children: [
                Text(
                  'A 6-digit code will be sent by SMS to confirm your phone number.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                _buildSubmitButton(),
                TextFormField(
                  controller: _smsController,
                  decoration:
                      const InputDecoration(labelText: 'Verification code'),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: ButtonStyle(),
                      // color: Colors.greenAccent[200],
                      onPressed: () async {
                        signInWithPhoneNumber();
                      },
                      child: Text("Sign in")),
                ),
              ],
            ),
          ),
        ));
  }
    List<Widget> _buildChildren() {
    return [
      SizedBox(height: 30.0),
      Text(
        'Enter your phone number',
        textScaleFactor: myDim.textScaleFactor,
        style: Theme.of(context).textTheme.subtitle2,
      ),
      SizedBox(height: 10.0),
      _buildPhoneField(),
      SizedBox(height: 20),
      _buildInfoText(),
      ElevatedButton(
        onPressed: () {},
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
        onPhoneNumberChange: onPhoneNumberChange,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
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
        initialPhoneNumber: phoneNumber,
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        verifyPhoneNumber();
      },
      child: Text('Next'),
    );
  }

  Future<void> verifyPhoneNumber() async {
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await widget.userToLink.linkWithCredential(phoneAuthCredential);
      await _auth.signInWithCredential(phoneAuthCredential);
      showSnackbar(
          "Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showSnackbar(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      showSnackbar('Please check your phone for the verification code.');
      _verificationId = verificationId;
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      showSnackbar("verification code: " + verificationId);
      _verificationId = verificationId;
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: "+91" + _phoneNumberController.text,
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number: $e");
    }
  }

  Future<void> signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );
      await widget.userToLink.linkWithCredential(credential);
      await _auth.signInWithCredential(credential);

      //showSnackbar("Successfully signed in UID: ${user.uid}");
    } catch (e) {
      showSnackbar("Failed to sign in: " + e.toString());
    }
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
