import 'dart:convert';
import 'dart:math';
// import 'package:ecellapp/core/res/errors.dart';
// import 'package:ecellapp/core/res/strings.dart';
// import 'package:ecellapp/core/utils/injection.dart';
// import 'package:ecellapp/core/utils/logger.dart';
import 'package:chatbot/core/utils/shared.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/errors.dart';

abstract class LoginRepository {
  /// Takes in login credentials (here id and password)
  /// Use by implementing this class
  Future<String?> login(String email, String password);
}

class APILoginRepository implements LoginRepository {
  @override
  Future<String?> login(String email, String password) async {
    http.Response? response;
    try {
      final Uri url = Uri.parse(
          "https://tech-server-chatbot1.onrender.com/auth/signin/user");

      response = await http.post(url, headers: <String, String>{
        'Context-Type': 'application/json;charSet=UTF-8'
      }, body: {
        "email": email,
        "password": password,
      });

      UserSimplePreferences.setEmail(json.decode(response.body)['email']);
      UserSimplePreferences.setPass(json.decode(response.body)['password']);
      UserSimplePreferences.setRoom(json.decode(response.body)['room']);
      UserSimplePreferences.setId(json.decode(response.body)['_id']);

      print("response:" + response.body);
    } catch (e) {
      print("hi");
      print(e);
    }

    if (response!.statusCode == 202) {
      try {
        String? token = json.decode(response.body)['_id'];
        return token;
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 400) {
      throw ValidationException(response.body);
    } else if (response.statusCode == 401 || response.statusCode == 404) {
      throw ResponseException(jsonDecode(response.body)['detail']);
    } else {
      throw UnknownException();
    }
  }
}
