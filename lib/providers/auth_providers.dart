import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/http_exception.dart';
import '../helpers/database.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String userId;

  Map<String, Object> userInfo = {
    'userName': '',
    'userEmail': '',
    'lastSeen': '',
    'imageUrl': ''
  };

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
     return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlMethod) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlMethod?key=AIzaSyCXonn0WBjGEM046pMQuKuLEEoT09ARYQA";
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else {
        _token = responseData['idToken'];
        userId = responseData['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      }
      print(_token);

      notifyListeners();

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': userId,
          'expiryDate': _expiryDate.toIso8601String()
        });
        prefs.setString('userData', userData);

        if (urlMethod == 'signInWithPassword') {
          updateLastSeen(userId);
        }

    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> register(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<bool> autologIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    userId = extractedData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    updateLastSeen(userId);
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    userId = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> getUserData(String userId) async {
    final ref = Firestore.instance.collection('users').document(userId);
    DocumentSnapshot snapshot = await ref.get();
    userInfo['userName'] = snapshot['name'];
    userInfo['userEmail'] = snapshot['email'];
    userInfo['imageUrl'] = snapshot['imageUrl'];
    userInfo['lastSeen'] = snapshot['lastseen'];
    notifyListeners();
  }
}
