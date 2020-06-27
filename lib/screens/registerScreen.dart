import 'package:flutter/material.dart';
import 'package:login_demo/exceptions/http_exception.dart';
import 'package:login_demo/model/userModel.dart';
import 'package:login_demo/provider/authProvider.dart';
import 'package:login_demo/screens/loginScreen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "registerScreen";
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  bool _hidePassword = true;

  String _fullName;

  String _phoneNo;

  String _email;

  String _password;

  String _confirmPassword;

  bool _isLoading = false;

  InputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      gapPadding: 0,
      borderSide: new BorderSide(color: Colors.white),
      borderRadius: new BorderRadius.circular(27),
    );
  }

  InputBorder _underLineInputBorder() {
    return UnderlineInputBorder(
      borderSide: new BorderSide(color: Colors.white),
      borderRadius: new BorderRadius.circular(27),
    );
  }

  TextFormField _textFormField(
      {bool obscureText,
      String hintText,
      Widget prefixIcon,
      Function(String) onSaved}) {
    return TextFormField(
      autofocus: true,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintStyle: Theme.of(context).textTheme.bodyText1,
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        focusColor: Colors.red,
        fillColor: Colors.blue[900].withOpacity(0.1),
        focusedBorder: _outlineInputBorder(),
        enabledBorder: _underLineInputBorder(),
        errorBorder: _outlineInputBorder(),
        focusedErrorBorder: _outlineInputBorder(),
        errorStyle: Theme.of(context).textTheme.subtitle,
      ),
      style: Theme.of(context).textTheme.title,
      onSaved: onSaved,
    );
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
    } else {
      _autoValidate = true;
    }
  }

  void _showErrorDialogue(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Error Occurred !"),
              content: Text(errorMessage),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> submit() async {
    final _formState = _formKey.currentState; //get current form data
    if (_formState.validate()) {
      _formState.save(); //to save all data of login form
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Auth>(context, listen: false)
            .signUp(UserModel("", _fullName, _email, _password, "", _phoneNo));
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      } on HttpException catch (error) {
        var errorMessage = "Authentication failed";
        if (error.toString().contains("EMAIL_EXISTS")) {
          errorMessage = 'This email address is already in use.';
        } else if (error.toString().contains("INVALID_EMAIL")) {
          errorMessage = 'This is not a valid email address.';
        } else if (error.toString().contains("WEAK_PASSWORD")) {
          errorMessage = 'This password is too weak.';
        } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
          errorMessage = 'Could not find a user with that email.';
        } else if (error.toString().contains("INVALID_PASSWORD")) {
          errorMessage = 'Invalid password.';
        }
        _showErrorDialogue(errorMessage);
      } catch (error) {
        const errorMessage = "Could not authenticate you. Please try again !!!";
        _showErrorDialogue(errorMessage);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          height: double.infinity,
          width: double.infinity,
          color: Colors.blueGrey,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Enrollment Form",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.title.copyWith(
                            color: Colors.white,
                            letterSpacing: 1,
                            fontFamily: "font2",
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      //color: Colors.white.withOpacity(0.9),
                      elevation: 5,
                      shadowColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        height: 400,
                        child: Form(
                          key: _formKey,
                          autovalidate: _autoValidate,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _textFormField(
                                  hintText: "Full Name",
                                  prefixIcon: Icon(Icons.person_outline),
                                  obscureText: false,
                                  onSaved: (value) {
                                    _fullName = value;
                                  }),
                              _textFormField(
                                  hintText: "Phone No",
                                  prefixIcon: Icon(Icons.phone),
                                  obscureText: false,
                                  onSaved: (value) {
                                    _phoneNo = value;
                                  }),
                              _textFormField(
                                  hintText: "E-mail",
                                  prefixIcon: Icon(Icons.email),
                                  obscureText: false,
                                  onSaved: (value) {
                                    _email = value;
                                  }),
                              _textFormField(
                                obscureText: _hidePassword,
                                hintText: "Password",
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                                onSaved: (value) {
                                  _password = value;
                                },
                              ),
                              _textFormField(
                                obscureText: _hidePassword,
                                hintText: "Confirm Password",
                                prefixIcon: IconButton(
                                  icon: Icon(Icons.remove_red_eye),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                                onSaved: (value) {
                                  _confirmPassword = value;
                                },
                              ),
                              _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        _validateInputs();
                                        submit();
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(0),
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.blueGrey.withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green,
                                              blurRadius: 0.5,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        alignment: Alignment.center,
                                        width: 150,
                                        height: 40,
                                        child: Text(
                                          "Register",
                                          style: Theme.of(context)
                                              .textTheme
                                              .title
                                              .copyWith(
                                                color: Colors.white,
                                                fontFamily: "font2",
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      LoginScreen.routeName);
                                },
                                child: Container(
                                  child: Text(
                                    "Already have an account ?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
