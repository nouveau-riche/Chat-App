import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/http_exception.dart';
import '../providers/auth_providers.dart';
import '../widgets/snackbar.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: mq.height,
        width: mq.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildTitleWidget(mq.width * 0.08, mq.height * 0.015),
            SizedBox(height: mq.height * 0.13),
            LoginAuth()
          ],
        ),
      ),
    );
  }
}

class LoginAuth extends StatefulWidget {
  @override
  _LoginAuthState createState() => _LoginAuthState();
}

class _LoginAuthState extends State<LoginAuth> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _focusPassword = FocusNode();
  String _email;
  String _password;
  var _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context,listen:false)
          .login(_email, _password);
      snackBarSuccess(context, "Welcome! $_email");
    } on HttpException catch (error) {
      var errormessage = "Authentication error";
      if (error.toString().contains('INVALID_PASSWORD')) {
        errormessage = 'Wrong Password!';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errormessage = 'Enter a valid email Id';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errormessage = 'User not found! Register';
      }
      snackBarError(context, errormessage);
    } catch (error) {
      const errormessage = "Internet connection too slow";
      snackBarError(context, errormessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _focusPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.08),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            getEmail(),
            SizedBox(height: mq.height * 0.02),
            getPassword(),
            SizedBox(height: mq.height * 0.06),
            _isLoading == true
                ? CircularProgressIndicator()
                : buildLoginButton(),
            buildRegisterButton(context)
          ],
        )),
      ),
    );
  }

  Widget getEmail() {
    return TextFormField(
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        prefixIcon: const Icon(Icons.email),
        hintText: 'Email Address',
        focusedBorder: const UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        _email = value;
      },
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (!value.contains('@') || value.isEmpty) {
          return 'Invalid Email';
        }
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_focusPassword);
      },
    );
  }

  Widget getPassword() {
    return TextFormField(
      obscureText: true,
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        prefixIcon: const Icon(Icons.vpn_key),
        hintText: 'Password',
        focusedBorder: const UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      onSaved: (value) {
        _password = value;
      },
      focusNode: _focusPassword,
      validator: (value) {
        if (value.length <= 3 || value.isEmpty) {
          return 'password length must be more than 3';
        }
      },
      textInputAction: TextInputAction.done,
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: RaisedButton(
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: _save,
      ),
    );
  }
}

Widget buildTitleWidget(double h1, double h2) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: h1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Welcome back!',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 30)),
        SizedBox(height: h2),
        const Text('Please login your account',
            style: TextStyle(color: Colors.grey, fontSize: 24)),
      ],
    ),
  );
}

Widget buildRegisterButton(BuildContext context) {
  return FlatButton(
    child: const Text(
      'REGISTER',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    ),
    onPressed: () {
      Navigator.of(context).pushReplacementNamed('/register-screen');
    },
  );
}
