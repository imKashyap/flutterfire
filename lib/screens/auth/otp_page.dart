import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:konnect/validators/form_validator.dart';
import 'package:konnect/widgets/my_clipper.dart';
import 'package:konnect/widgets/platform_exception_alert_dialog.dart';


class OtpPage extends StatefulWidget with FormValidator {
  final String phoneNo;
  final String sessionId;
  OtpPage({
    Key key,
    @required this.phoneNo,
    @required this.sessionId,
  }) : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String get sessid => _hasResent ? newSessionId : widget.sessionId;

  // ToastWidget _toast;
  // @override
  void initState() {
    super.initState();
    _startTimer();
  }

  String newSessionId = '';
  String _otp = '';
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isResending = false;
  bool _hasResent = false;
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller5 = TextEditingController();
  final TextEditingController _controller6 = TextEditingController();
  final FocusNode _otpFocusNode1 = FocusNode();
  final FocusNode _otpFocusNode2 = FocusNode();
  final FocusNode _otpFocusNode3 = FocusNode();
  final FocusNode _otpFocusNode4 = FocusNode();
  final FocusNode _otpFocusNode5 = FocusNode();
  final FocusNode _otpFocusNode6 = FocusNode();
  String get otpErroText {
    bool showErrorText = _isSubmitted && !widget.otpValidator.isValid(_otp);
    return showErrorText ? widget.otpError : null;
  }

  @override
  void dispose() {
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
    _otpFocusNode1.dispose();
    _otpFocusNode2.dispose();
    _otpFocusNode3.dispose();
    _otpFocusNode4.dispose();
    _otpFocusNode5.dispose();
    _otpFocusNode6.dispose();
  }

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
        body: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              height: myDim.height * 0.3,
              padding: const EdgeInsets.only(top: 10.0),
              child: Image(
                image: AssetImage('assets/images/phone.png'),
              ),
            ),
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                height: myDim.height * 0.7,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: kColorPrimaryDark,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildChildren(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    const SizedBox spacebox = SizedBox(
      height: 15.0,
    );
    return [
      SizedBox(
        height: myDim.height * 0.12,
      ),
      _buildInfoText(),
      spacebox,
      _buildOtpInput(),
      spacebox,
      spacebox,
      ElevatedButton(
          onPressed: _isLoading ? null : _verifyOtp,
          child: _isLoading
              ? SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      spacebox,
      GestureDetector(
          onTap: _counter > 0 ? () {} : _resendOtp,
          child: _isResending
              ? SizedBox(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.0,
                  ),
                  height: 25.0,
                  width: 25.0,
                )
              : Text(
                  _counter > 0
                      ? 'Resend code in $_counter s.'
                      : 'Resend code now.',
                  textScaleFactor: myDim.textScaleFactor,
                  style: TextStyle(
                      color: Colors.white, fontSize: myDim.width * 0.045),
                )),
      spacebox,
      Container(
        height: myDim.height * 0.07,
        width: double.maxFinite,
        child: OutlineButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40.0),
            ),
          ),
          borderSide: BorderSide(color: Colors.white),
          onPressed: () {
            _timer.cancel();
            Navigator.of(context).pop();
          },
          child: Text('Reset Mobile Number',
              textScaleFactor: myDim.textScaleFactor,
              style: TextStyle(
                  color: Colors.white, fontSize: myDim.width * 0.045)),
        ),
      )
    ];
  }

  Widget _buildInfoText() {
    return Column(
      children: [
        Text(
          'Enter OTP',
          textScaleFactor: myDim.textScaleFactor,
          style: TextStyle(
            color: Colors.white,
            fontSize: myDim.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A One Time Password has been sent to ',
              textScaleFactor: myDim.textScaleFactor,
              style: TextStyle(
                color: Colors.white,
                fontSize: myDim.width * 0.04,
              ),
            ),
            Text(
              widget.phoneNo,
              textScaleFactor: myDim.textScaleFactor,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: myDim.width * 0.04,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNumInputBox(_otpFocusNode2, null, null, _controller1),
        _buildNumInputBox(
            _otpFocusNode3, _otpFocusNode2, _otpFocusNode1, _controller2),
        _buildNumInputBox(
            _otpFocusNode4, _otpFocusNode3, _otpFocusNode2, _controller3),
        _buildNumInputBox(
            _otpFocusNode5, _otpFocusNode4, _otpFocusNode3, _controller4),
        _buildNumInputBox(
            _otpFocusNode6, _otpFocusNode5, _otpFocusNode4, _controller5),
        _buildNumInputBox(null, _otpFocusNode6, _otpFocusNode5, _controller6)
      ],
    );
  }

  Widget _buildNumInputBox(FocusNode nextNode, FocusNode myFocus,
      FocusNode prevNode, TextEditingController controller) {
    return Container(
      width: 45.0,
      height: 50.0,
      child: TextField(
        controller: controller,
        maxLength: 1,
        maxLengthEnforced: true,
        textAlign: TextAlign.center,
        focusNode: myFocus,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          filled: true,
          errorText: otpErroText == null ? null : '',
          fillColor: Colors.black,
          enabled: _isLoading == false,
        ),
        enabled: !_isLoading && !_isResending,
        keyboardType: TextInputType.numberWithOptions(),
        textInputAction:
            nextNode == null ? TextInputAction.done : TextInputAction.next,
        onChanged: (val) {
          if (nextNode != null && val.trim().isNotEmpty)
            FocusScope.of(context).requestFocus(nextNode);
          else if (prevNode != null && val.trim().isEmpty)
            FocusScope.of(context).requestFocus(prevNode);
        },
        onEditingComplete: () {
          if (nextNode != null)
            FocusScope.of(context).requestFocus(nextNode);
          else
            _verifyOtp();
        },
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
    _otp = _controller1.text +
        _controller2.text +
        _controller3.text +
        _controller4.text +
        _controller5.text +
        _controller6.text;
    if (!widget.otpValidator.isValid(_otp)) return;
    try {
      setState(() {
        _isLoading = true;
      });
      // await Provider.of<AuthHandler>(context, listen: false).verifyOtp(
      //   phoneNo: widget.phoneNo,
      //   otp: _otp,
      //   sessionId: sessid,
      // );
      _timer.cancel();
      Navigator.pop(context);
    } on PlatformException catch (e) {
      showErrorDialog(e);
    } finally {
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
      // final thisSessionId =
      //     await Provider.of<AuthHandler>(context, listen: false)
      //         .generateOtp(widget.phoneNo);
      // _toast.showToast('Code Resent');
      // newSessionId = thisSessionId;
      setState(() {
        _startTimer();
      });
    } on PlatformException catch (e) {
      showErrorDialog(e);
    } finally {
      setState(() {
        _isResending = false;
        _hasResent = true;
      });
    }
  }

  void showErrorDialog(PlatformException e) {
    PlatfromrExceptionAlertDialog(title: 'Verification Failed', e: e)
        .show(context);
  }
}
