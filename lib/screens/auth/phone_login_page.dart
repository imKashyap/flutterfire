import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnect/screens/auth/otp_page.dart';
import 'package:konnect/screens/auth/phone_login_ui.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:konnect/validators/form_validator.dart';
import 'package:konnect/widgets/platform_exception_alert_dialog.dart';

class PhoneLoginPage extends StatefulWidget with FormValidator {
  @override
  _PhoneLoginPageState createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;
  String _countryCode = '91';
  String initialCountry = 'IN';

  String get phone => _phoneController.text.trim();
  bool get canSubmit {
    return widget.phoneValidator.isValid(phone) && !_isLoading;
  }

  String get phoneErrorText {
    bool showErrorText = _isSubmitted && !widget.phoneValidator.isValid(phone);
    return showErrorText ? widget.phoneError : null;
  }

  Dimensions myDim;
  @override
  Widget build(BuildContext context) {
    myDim = Dimensions(context);
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Sign In'),
        ),
        body: PhoneLoginUI(
          type: loginType.login,
          callback: () {},
        ));
  }

  List<Widget> _buildChildren() {
    double totalHeight = myDim.height - myDim.statusBarHeight;
    return [
      _welcomeText(),
      Text(
        'Enter phone number',
        style: Theme.of(context)
            .textTheme
            .headline5
            .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      Row(
        children: <Widget>[
          // CountryPickerDropdown(
          //   initialValue: 'in',
          //   itemBuilder: _buildDropdownItem,
          //   onValuePicked: (Country country) {
          //     // print("${country.name}");
          //   },
          // ),
          Expanded(
            child: TextField(
              controller: _phoneController,
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
      Container(
        alignment: Alignment.center,
        height: totalHeight * 0.15,
        child: RaisedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? SizedBox(
                  child: CircularProgressIndicator(
                    //valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.0,
                  ),
                  height: 25.0,
                  width: 25.0,
                )
              : Text(
                  'Next',
                  textScaleFactor: myDim.textScaleFactor,
                  style: TextStyle(
                      color: Colors.white, fontSize: myDim.width * 0.05),
                ),
        ),
      )
    ];
  }

  // Widget _buildDropdownItem(Country country) => Container(
  //       child: Row(
  //         children: <Widget>[
  //           CountryPickerUtils.getDefaultFlagImage(country),
  //           SizedBox(
  //             width: 8.0,
  //           ),
  //           Text("+${country.phoneCode}"),
  //         ],
  //       ),
  //     );

  Column _welcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  void _submit() async {
    setState(() {
      _isSubmitted = true;
    });
    if (!canSubmit) return;
    setState(() {
      _isLoading = true;
    });
    try {
      // final sessionId = await Provider.of<AuthHandler>(context, listen: false)
      //     .generateOtp('+' + _countryCode + phone);
      // ToastWidget(context).showToast('OTP Sent');
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => OtpPage(
                phoneNo: '+' + _countryCode + phone,
                sessionId: 'sessionId',
              )));
    } on PlatformException catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(e);
    }
  }

  void showErrorDialog(PlatformException e) {
    PlatfromrExceptionAlertDialog(title: 'Sign In Failed', e: e).show(context);
  }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }
}
