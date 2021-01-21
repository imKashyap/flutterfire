import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/models/konnector.dart';

class AddPhonePage extends StatefulWidget {
  final User userToLink;

  AddPhonePage(this.userToLink);

  @override
  _AddPhonePageState createState() => _AddPhonePageState();
}

class _AddPhonePageState extends State<AddPhonePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  String _verificationId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter phone number',
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    CountryPickerDropdown(
                      initialValue: 'in',
                      itemBuilder: _buildDropdownItem,
                      onValuePicked: (Country country) {
                        // print("${country.name}");
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone Number",
                        ),
                        onChanged: (value) {
                          // this.phoneNo=value;
                          // print(value);
                        },
                      ),
                    ),
                  ],
                ),
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
                  child: RaisedButton(
                      color: Colors.greenAccent[200],
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

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode}"),
          ],
        ),
      );

  Widget _buildSubmitButton() {
    return RaisedButton(
      onPressed: () async {
        verifyPhoneNumber();
      },
      child: Text('Next'),
    );
  }

  Future<void> verifyPhoneNumber() async {
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      widget.userToLink.linkWithCredential(phoneAuthCredential);
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
          phoneNumber: "+91"+_phoneNumberController.text,
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number: ${e}");
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
