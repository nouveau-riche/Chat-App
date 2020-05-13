import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/http_exception.dart';
import '../widgets/snackbar.dart';
import '../providers/auth_providers.dart';
import '../helpers/media.dart';
import '../helpers/database.dart';
import '../helpers/storage.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        height: mq.height,
        width: mq.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitleWidget(mq.width * 0.08, mq.height * 0.015),
            SizedBox(height: mq.height * 0.029),
            RegisterAuth(),
          ],
        ),
      ),
    );
  }
}

class RegisterAuth extends StatefulWidget {
  @override
  _RegisterAuthState createState() => _RegisterAuthState();
}

class _RegisterAuthState extends State<RegisterAuth> {
  final GlobalKey<FormState> _FormKey = GlobalKey();
  final _focusEmaill = FocusNode();
  final _focusPasswordd = FocusNode();

  String _name;
  String _emaill;
  String _passwordd;
  var _isLoading = false;

  File _choosedImage;

  Future<void> _saveReg() async {
    if (!_FormKey.currentState.validate()) {
      return;
    }
    _FormKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .register(_emaill, _passwordd);
      //snackBarSuccess(context, 'User registered');
      //final uid = Provider.of<AuthProvider>(context, listen: false).userId;
      //var result = await uploadProfilePicture(uid, _choosedImage);
      //var _imageUrl = await result.ref.getDownloadURL();
      //await createDatabase(uid, _name, _emaill, _imageUrl);
    } on HttpException catch (error) {
      var errormessage = "Registration error";
      if (error.toString().contains('INVALID_EMAIL')) {
        errormessage = 'Enter a valid email Id';
      } else if (error.toString().contains('EMAIL_EXISTS')) {
        errormessage = 'Email already exists';
      }
      snackBarError(context, errormessage);
    } catch (error) {
      const errormessage = 'Internet connection too slow';
      snackBarError(context, errormessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _focusEmaill.dispose();
    _focusPasswordd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.08),
      child: Form(
        key: _FormKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                child: GestureDetector(
                  onTap: () async {
                    File _image = await ChosseImage();
                    setState(() {
                      _choosedImage = _image;
                    });
                  },
                  child: Container(
                    height: mq.height * 0.1,
                    width: mq.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: _choosedImage != null
                            ? Image.file(_choosedImage, fit: BoxFit.cover)
                            : Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQIb_yOMUqLK4WMjy2iRUMPq520_p7Ey_0Ba1CWWvFLCp-KYvCm&usqp=CAU')),
                  ),
                ),
              ),
              _getName(),
              SizedBox(height: mq.height * 0.011),
              _getEmail(),
              SizedBox(height: mq.height * 0.011),
              _getPassword(),
              SizedBox(height: mq.height * 0.025),
              _isLoading == true
                  ? CircularProgressIndicator()
                  : _buildRegisterButton(),
              SizedBox(height: mq.height * 0.011),
              _backToLogin(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget _getName() {
    return TextFormField(
      textCapitalization: TextCapitalization.words,
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        hintText: 'Name',
        prefixIcon: const Icon(Icons.person),
        focusedBorder: const UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      keyboardType: TextInputType.text,
      onSaved: (value) {
        _name = value;
      },
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_focusEmaill);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter name';
        }
      },
    );
  }

  Widget _getEmail() {
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
      focusNode: _focusEmaill,
      onSaved: (value) {
        _emaill = value;
      },
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (!value.contains('@') || value.isEmpty) {
          return 'Invalid Email';
        }
      },
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_focusPasswordd);
      },
    );
  }

  Widget _getPassword() {
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
        _passwordd = value;
      },
      focusNode: _focusPasswordd,
      validator: (value) {
        if (value.length <= 3 || value.isEmpty) {
          return 'password length must be more than 3';
        }
      },
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: RaisedButton(
        child: const Text(
          'REGISTER',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: _saveReg,
      ),
    );
  }
}

Widget _buildTitleWidget(double h1, double h2) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: h1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Let\'s get going!',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 30)),
        SizedBox(height: h2),
        const Text('Please enter your details',
            style: TextStyle(color: Colors.grey, fontSize: 24)),
      ],
    ),
  );
}

Widget _backToLogin(BuildContext context) {
  return IconButton(
    icon: const Icon(
      Icons.arrow_back,
      size: 40,
    ),
    onPressed: () {
      Navigator.of(context).pushReplacementNamed('/login-screen');
    },
  );
}
