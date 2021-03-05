import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnect/models/email_sign_in_model.dart';
import 'package:konnect/sevices/auth.dart';
import 'package:konnect/utils/colors.dart';
import 'package:konnect/widgets/platform_alert_dialog.dart';
import 'package:provider/provider.dart';

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({@required this.model});
  final EmailSignInModel model;

  static Widget create(BuildContext context, bool toLink, String previousEmail,
      AuthCredential creds) {
    final auth = Provider.of<AuthBase>(context);
    return ChangeNotifierProvider<EmailSignInModel>(
      create: (_) => EmailSignInModel(
          auth: auth,
          toLink: toLink,
          creds: creds,
          previousEmail: previousEmail),
      child: Consumer<EmailSignInModel>(
        builder: (context, model, _) => EmailSignInForm(
          model: model,
        ),
      ),
    );
  }

  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _showPass = true;

  EmailSignInModel get model => widget.model;

  Future<void> _submit() async {
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on PlatformException catch (e) {
      PlatformAlertDialog(
        title: 'Sign in failed',
        content: e.message,
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  Future<void> _sendPassResetMail() async {
    try {
      await model.resetPass();
    } on PlatformException catch (e) {
      PlatformAlertDialog(
        title: 'Failed to send Password reset email',
        content: e.message,
        defaultActionText: 'OK',
      ).show(context);
    }
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    return [
      _welcomeText(),
      SizedBox(height: 30.0),
      _buildEmailTextField(),
      SizedBox(height: 8.0),
      _buildPasswordTextField(),
      model.formType == EmailSignInFormType.signIn
          ? _buildForgotPassword()
          : Padding(padding: const EdgeInsets.all(8.0)),
      SizedBox(height: 8.0),
      model.isLoading
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
                child: Text(model.primaryButtonText),
              ),
            ),
      SizedBox(height: 8.0),
      TextButton(
        child: Text(
          model.secondaryButtonText,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        onPressed: !model.isLoading ? _toggleFormType : null,
      ),
    ];
  }

  Column _welcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.primaryWelcomeText,
          style: Theme.of(context).textTheme.headline5.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(
          height: 3.0,
        ),
        Text(
          model.secondaryWelcomeText,
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmailTextField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.all(Radius.circular(6.0))),
      child: Row(
        children: [
          Container(
            width: 100.0,
            padding: const EdgeInsets.only(left: 15.0, right: 20.0),
            child: Text(
              'Email',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Expanded(
            child: TextField(
              style: Theme.of(context).textTheme.bodyText2,
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                  hintText: 'example@abc.com',
                  errorText: model.emailErrorText,
                  enabled: model.isLoading == false,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade900),
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: model.updateEmail,
              onEditingComplete: () => _emailEditingComplete(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.all(Radius.circular(6.0))),
      child: Row(
        children: [
          Container(
            width: 100.0,
            padding: const EdgeInsets.only(left: 15.0, right: 20.0),
            child: Text(
              'Password',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Expanded(
            child: TextField(
              style: Theme.of(context).textTheme.bodyText2,
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                suffix: GestureDetector(
                    child: Icon(
                      _showPass ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey.shade500,
                    ),
                    onTap: () {
                      setState(() {
                        _showPass = !_showPass;
                      });
                    }),
                hintText: 'At least 6 characters',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
                errorText: model.passErrorText,
                enabled: model.isLoading == false,
              ),
              obscureText: _showPass,
              textInputAction: TextInputAction.done,
              onChanged: model.updatePassword,
              onEditingComplete: _submit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _sendPassResetMail,
            child: Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        ),
      ),
    );
  }
}
