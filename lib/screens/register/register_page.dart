import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/utils/dimensions.dart';
import 'package:konnect/validators/form_validator.dart';
import 'package:konnect/widgets/image_input.dart';
import 'package:provider/provider.dart';
// import 'package:konnect/widgets/toast_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget with FormValidator {
  final User userToRegister;
  RegisterPage(this.userToRegister);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool _isSubmitted = false;
  File _pickedImage;
  int _gender = 0;
  Dimensions myDim;

  bool get canSubmit => name != null;
  void _selectImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  // ToastWidget _toast;
  // @override
  // void initState() {
  //   super.initState();
  //   _toast = ToastWidget();
  // }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
  }

  String get name => _nameController.text.trim();

  String get nameErrorText {
    bool showErrorText =
        _isSubmitted && !widget.nonEmptyTextValidator.isValid(name);
    return showErrorText ? widget.emptyname : null;
  }

  AuthBase auth;
  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context, listen: false);
    myDim = Dimensions(context);
    const spaceBox = SizedBox(
      height: 10.0,
    );
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30.0,
              horizontal: 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Konnect',
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            color: kColorPrimary,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' better.\nAnytime. Anywhere.',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                  spaceBox,
                  spaceBox,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                    child: Center(
                        child: ImageInput(_selectImage, InputType.profile)),
                  ),
                  spaceBox,
                  _buildCustomTextField(
                      controller: _nameController,
                      prefix: Icons.person_outline,
                      label: 'Name',
                      hint: '',
                      inputType: TextInputType.name,
                      errorText: nameErrorText,
                      textCapitals: TextCapitalization.words,
                      shiftFocusTo: null),
                  spaceBox,
                  spaceBox,
                  _buildGenderRadios(),
                  spaceBox,
                  _buildSubmitButton(),
                  spaceBox,
                  Text(
                    'Filling up the details accurately will help us ensure an easy connection to your favorites.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildCustomTextField(
      {TextEditingController controller,
      FocusNode myFocus,
      IconData prefix,
      String label,
      String hint,
      TextInputType inputType,
      TextCapitalization textCapitals,
      String errorText,
      FocusNode shiftFocusTo}) {
    return TextField(
        focusNode: myFocus,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            prefix,
          ),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: kColorPrimary,
          )),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          labelText: label,
          hintText: hint,
          errorText: errorText,
        ),
        autocorrect: false,
        textCapitalization: textCapitals,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        onChanged: (val) {
          setState(() {});
        },
        onEditingComplete: () {
          shiftFocusTo == null
              ? _submit()
              : FocusScope.of(context).requestFocus(shiftFocusTo);
        });
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => kColorPrimary),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (Set<MaterialState> states) => RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: Colors.transparent)),
            )),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text('Submit'),
        ),
      ),
    );
  }

  void _submit() async {
    await auth.signOut();
    //User thisUser = widget.userToRegister;
    // Konnector registeredUser = Konnector(
    //     id: thisUser.uid,
    //     name: name,
    //     email: thisUser.email,
    //     phoneNo: thisUser.phoneNumber,
    //     gender: _gender==0?'M':'F',
    //     photoUrl: '');
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    // await users.doc(registeredUser.id).set({
    //   'id': registeredUser.id,
    //   'name': registeredUser.name,
    //   'email': registeredUser.email,
    //   'phoneNo': registeredUser.phoneNo
    // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', 'user');
    Navigator.of(context).pop();
  }

  Widget _buildGenderRadios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your Gender',
        ),
        Row(children: [
          Container(
            width: myDim.width * 0.4,
            child: RadioListTile(
                activeColor: kColorPrimary,
                title: Text('Male'),
                value: 0,
                groupValue: _gender,
                onChanged: (value) {
                  _setValue(value);
                }),
          ),
          Container(
            width: myDim.width * 0.4,
            child: RadioListTile(
                activeColor: kColorPrimary,
                title: Text('Female'),
                value: 1,
                groupValue: _gender,
                onChanged: (value) {
                  _setValue(value);
                }),
          )
        ]),
      ],
    );
  }

  void _setValue(int value) => setState(() => _gender = value);
}
