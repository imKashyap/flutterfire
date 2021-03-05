import 'package:international_phone_input/international_phone_input.dart';
import 'package:flutter/material.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';

enum loginType { login, register }

class PhoneLoginUI extends StatefulWidget {
  final loginType type;
  final Function callback;
  const PhoneLoginUI({@required this.type, @required this.callback});
  @override
  _PhoneLoginUIState createState() => _PhoneLoginUIState();
}

class _PhoneLoginUIState extends State<PhoneLoginUI> {
  Dimensions myDim;
  @override
  Widget build(BuildContext context) {
    myDim = Dimensions(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: myDim.width * 0.04, vertical: myDim.height * 0.01),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(),
          ),
        ),
      ),
    );
  }

  String phoneNumber;
  String phoneIsoCode;
  bool visible = true;
  String confirmedNumber = '';

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNumber = number;
      phoneIsoCode = isoCode;
    });
  }

  List<Widget> _buildChildren() {
    return [
      _welcomeText(),
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
}
