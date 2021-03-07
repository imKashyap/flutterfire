import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnect/managers/email_signin_manager.dart';
import 'package:konnect/models/email_sign_in_model.dart';
import 'package:konnect/sevices/phone_auth_model.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:konnect/validators/form_validator.dart';
import 'package:konnect/widgets/platform_exception_alert_dialog.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utils/colors.dart';
import '../register/register_page.dart';

class OtpPageUI extends StatefulWidget with FormValidator {
  final PhoneAuthModel model;
  OtpPageUI({
    Key key,
    @required this.model,
  }) : super(key: key);

  @override
  _OtpPageUIState createState() => _OtpPageUIState();
}

class _OtpPageUIState extends State<OtpPageUI> {
  // ToastWidget _toast;
  @override
  void initState() {
    super.initState();
    _startTimer();
    errorController = StreamController<ErrorAnimationType>();
  }

  bool _isLoading = false;
  bool _isSubmitted = false;

  PhoneAuthModel get model => widget.model;
  bool _isResending = false;

  String get otpErroText {
    bool showErrorText = !widget.otpValidator.isValid(model.otp);
    return showErrorText ? widget.otpError : null;
  }

  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  StreamController<ErrorAnimationType> errorController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Dimensions myDim;
  @override
  Widget build(BuildContext context) {
    myDim = Dimensions(context);
    return WillPopScope(
      onWillPop: () async {
        _timer.cancel();
        Navigator.of(context).pop();
        await Future.delayed(Duration(milliseconds: 0));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: myDim.width * 0.04, vertical: myDim.height * 0.01),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildChildren()),
        )),
      ),
    );
  }

  List<Widget> _buildChildren() {
    const SizedBox spacebox = SizedBox(
      height: 15.0,
    );
    return [
      _buildInfoText(),
      spacebox,
      spacebox,
      _buildOTPField(),
      spacebox,
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
          : _buildVerifyButton(),
      spacebox,
      GestureDetector(
          onTap: _counter > 0 || _isLoading ? null : _resendOtp,
          child: _isResending
              ? Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                    height: 25.0,
                    width: 25.0,
                  ),
                )
              : Text(
                  _counter > 0
                      ? 'Resend code in $_counter s.'
                      : 'Resend code now.',
                  textAlign: TextAlign.center,
                  textScaleFactor: myDim.textScaleFactor,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.white,
                      ),
                )),
      spacebox,
      spacebox,
      Container(
        height: myDim.height * 0.07,
        width: double.maxFinite,
        child: OutlinedButton(
          style: ButtonStyle(
            side: MaterialStateProperty.resolveWith<BorderSide>(
                (Set<MaterialState> states) =>
                    BorderSide(color: kColorPrimary)),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (Set<MaterialState> states) => RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
              ),
            ),
          ),
          onPressed: _isLoading || _isResending
              ? null
              : () {
                  _timer.cancel();
                  Navigator.of(context).pop();
                },
          child: Text(
            'Reset Mobile Number',
            textScaleFactor: myDim.textScaleFactor,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      )
    ];
  }

  Widget _buildInfoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number Verification',
          textScaleFactor: myDim.textScaleFactor,
          style: TextStyle(
            color: Colors.white,
            fontSize: myDim.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: myDim.height * 0.02,
        ),
        Center(
          child: Column(
            children: [
              Text(
                'Enter the 6-digit code sent to ',
                textAlign: TextAlign.center,
                textScaleFactor: myDim.textScaleFactor,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: myDim.width * 0.04,
                ),
              ),
              Text(
                model.phoneNo,
                textAlign: TextAlign.center,
                textScaleFactor: myDim.textScaleFactor,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  fontSize: myDim.width * 0.04,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField() {
    return PinCodeTextField(
      textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
      appContext: context,
      pastedTextStyle: TextStyle(
        color: Colors.green.shade600,
        fontWeight: FontWeight.bold,
      ),
      length: 6,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        activeColor: Colors.grey.shade900,
        inactiveColor: _isSubmitted ? Colors.red : Colors.grey.shade900,
        selectedColor: _isSubmitted ? Colors.red : Colors.grey.shade900,
        inactiveFillColor: Colors.grey.shade900,
        selectedFillColor: Colors.grey.shade900,
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(3),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.grey.shade900,
      ),
      cursorColor: Colors.white,
      animationDuration: Duration(milliseconds: 300),
      backgroundColor: Colors.black,
      enableActiveFill: true,
      errorAnimationController: errorController,
      controller: textEditingController,
      keyboardType: TextInputType.number,
      boxShadows: [
        BoxShadow(
          offset: Offset(0, 1),
          color: Colors.black12,
          blurRadius: 10,
        )
      ],
      onCompleted: (value) {
        model.updateOtp(value);
        _verifyOtp();
      },
      onChanged: (value) {
        model.updateOtp(value);
      },
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: !_isLoading || _isResending ? _verifyOtp : null,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) => kColorPrimary)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('Verify'),
      ),
    );
  }

  int _counter = 45;
  Timer _timer;

  void _startTimer() {
    _counter = 45;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (!model.isValidOtp) {
      setState(() {
        _isSubmitted = true;
      });
      errorController.add(ErrorAnimationType.shake);
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        AuthCredential creds = await model.signInWithPhoneNumber();
        creds != null
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => EmailSignInManager(
                          type: EmailSignInFormType.signUp,
                          toLink: true,
                          creds: creds,
                          linkType:LinkType.phone
                        )),
                (Route<dynamic> route) => false)
            : Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => RegisterPage(model.userToLink)),
                ModalRoute.withName('\main'));
      } catch (e) {
        print("error " + e.message);
      }
      _timer.cancel();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    try {
      setState(() {
        _isResending = true;
      });
      setState(() {
        _startTimer();
      });
      try {
        await model.verifyPhoneNumber();
      } catch (e) {
        print("error " + e.message);
      }
    } on PlatformException catch (e) {
      showErrorDialog(e);
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  void showErrorDialog(PlatformException e) {
    PlatfromrExceptionAlertDialog(title: 'Verification Failed', e: e)
        .show(context);
  }

  @override
  void dispose() {
    super.dispose();
    errorController.close();
  }
}
