import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_demo/exceptions/http_exception.dart';
import 'package:login_demo/model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token; //expires after one hour
  DateTime _expiryDate;
  String _userId;
  String _userType;
  Timer _authTimer; //to create timer

  //login and sign up firebase authentication according to rest api
  //this method was created to reduce the duplication of code in sign up and
  // login method
  Future<void> _authenticate({String urlSegment, UserModel userModel}) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA4Oo4-BJG3FjbZg_znGXK5Nyujsb3Q_u0";
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            "email": userModel.email,
            "password": userModel.password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      //if response data error contains value then it will throw http
      // exception like email_not_found, email_exists etc
      if (responseData['error'] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      //if response data error does not contain any value then token, userId
      // and expiry date value are assigned from response data
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      //set expiry Date / time for 1hr
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData["expiresIn"],
          ),
        ),
      );
      //if url segment is sign up then new users are added to firebase in
      // users table  otherwise it will fetch users data from user table
      // according to userId
      if (urlSegment == "signUp") {
        await addNewUsersToDatabase(_token, _userId, userModel);
      } else {
        _userType = await getUsers(_token, _userId);
        notifyListeners();
      }
      _autoLogout(); //added
      notifyListeners();
      //initialized share preferences
      final _prefs = await SharedPreferences.getInstance();
      final _userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userType': _userType,
        'expiryDate': _expiryDate.toIso8601String()
      });
      _prefs.setString("userData", _userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

  //this method will be called when new users want to enroll
  Future<void> signUp(UserModel userModel) async {
    return _authenticate(urlSegment: "signUp", userModel: userModel);
  }

  //this method will be called if users are already registered in firebase
  Future<void> login(UserModel userModel) async {
    return _authenticate(
        urlSegment: "signInWithPassword", userModel: userModel);
  }

  //check in firebase whether users table contain any users or not. if it
  // does not contains any users then first registered users will be super
  // user i.e. admin otherwise client
  Future<String> checkUsersTable() async {
    final _url = "https://login-demo-8b432.firebaseio.com/users.json";
    final _response = await http.get(_url);
    final _extractedData = jsonDecode(_response.body) as Map<String, dynamic>;
    if (_extractedData == null) {
      return "admin";
    } else {
      return "client";
    }
  }

  //add new users to firebase in users table according to userId
  Future<void> addNewUsersToDatabase(
      String authToken, String userId, UserModel userModel) async {
    String _userType = await checkUsersTable();
    final url =
        "https://login-demo-8b432.firebaseio.com/users/$userId.json?auth=$authToken";
    try {
      final _response = await http.put(url,
          body: json.encode({
            'userId': userId,
            'fullName': userModel.fullName,
            'phoneNo': userModel.phoneNo,
            'email': userModel.email,
            'password': userModel.password,
            'userType': _userType,
          }));
      //print((json.decode(response.body)));
    } catch (error) {
      throw error;
    }
  }

  //get users from firebase according to userId
  Future<String> getUsers(String authToken, String userId) async {
    final url = "https://login-demo-8b432.firebaseio.com/users/$userId"
        ".json?auth=$authToken";
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      return extractedData["userType"];
    } catch (error) {
      throw error;
    }
  }

  //check user is already login or not
  bool get isAuth {
    return _token != null;
  }

  //get userType of users
  String get userType {
    return _userType;
  }

  //manual logout by users
  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    _userType = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    //clean share preference data
    final _prefs = await SharedPreferences.getInstance();
    _prefs.clear();
  }

  //auto logout by system by checking expiry date
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final _timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: _timeToExpiry), logout);
  }

  //auto login
  Future<bool> autoLogin() async {
    final _prefs = await SharedPreferences.getInstance();
    if (!_prefs.containsKey("userData")) {
      return false;
    }
    final _extractedData =
        json.decode(_prefs.getString("userData")) as Map<String, Object>;

    final expiryDate = DateTime.parse(_extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = _extractedData['token'];
    _userId = _extractedData['userId'];
    _userType = _extractedData['userType'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }
}
