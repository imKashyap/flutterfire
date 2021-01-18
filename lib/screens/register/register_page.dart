import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:konnect/models/person.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/validators/form_validator.dart';
import 'package:konnect/widgets/image_input.dart';
import 'package:konnect/widgets/toast_widget.dart';

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

  bool get canSubmit => (name != null && _pickedImage != null);
  void _selectImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  ToastWidget _toast;
  @override
  void initState() {
    super.initState();
    _toast = ToastWidget();
  }

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

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
                    child: Center(
                        child: ImageInput(_selectImage, InputType.profile)),
                  ),
                  SizedBox(height: 10.0),
                  _buildDetailsInputField(),
                  SizedBox(height: 10.0),
                  _buildSubmitButton(),
                  SizedBox(height: 10.0),
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

  Widget _buildDetailsInputField() {
    const spaceBox = SizedBox(
      height: 20.0,
    );
    return Container(
      child: Column(
        children: [
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
          // _buildCustomTextField(
          //     controller: _emailController,
          //     myFocus: _emailInput,
          //     prefix: Icons.email_outlined,
          //     label: 'Email Address',
          //     errorText: emailErrorText,
          //     textCapitals: TextCapitalization.none,
          //     inputType: TextInputType.emailAddress,
          //     hint: 'you@example.com',
          //     shiftFocusTo: null),
        ],
      ),
    );
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
      child: RaisedButton(
        onPressed: () {},
        color: kColorPrimaryDark,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text('Submit'),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(color: Colors.transparent)),
      ),
    );
  }

  void _submit() async {
    User thisUser = widget.userToRegister;
    Person registeredUser =
        Person(thisUser.uid, name, thisUser.email, thisUser.phoneNumber);
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc().set({
      'id': registeredUser.id,
      'name': registeredUser.name,
      'email': registeredUser.email,
      'phoneNo': registeredUser.phoneNo
    });
  }
}
