import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_logger/http_logger.dart';
import 'package:http_middleware/http_with_middleware.dart';
import 'model/LoginPostData.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginPage> {
  //state
  GlobalKey<FormState> _key = GlobalKey();

  //controllers
  var emailTextFieldController = TextEditingController();
  var passwordTextFieldController = TextEditingController();
  var _autoValidator = false;
  var obscurePassword = true;
  String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(),
    );
  }

  Widget _buildPageContent() {
    return Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.white,
        child: Form(
            key: _key,
            autovalidate: _autoValidator,
            child: getLoginForm(context)));
  }

  Widget getLoginForm(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Login",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.black54),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 200,
              child: Image.asset('assets/img/logo.png'),
            ),
            SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            TextFormField(
              controller: emailTextFieldController,
              validator: validateEmail,
              autovalidate: _autoValidator,
              onSaved: (String val) {
                email = val;
              },
              style: TextStyle(color: Colors.black54),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38),
              ),
            ),
            Divider(
              color: Colors.black54,
            ),
            SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            TextFormField(
              controller: passwordTextFieldController,
              validator: validatePassword,
              autovalidate: _autoValidator,
              onSaved: (String val) {
                password = val;
              },
              style: TextStyle(color: Colors.black54),
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
                suffixIcon:
                    IconButton(icon: getVisibilityIcon(), onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    }),
              ),
            ),
            Divider(
              color: Colors.black54,
            ),
            SizedBox(
              height: 50,
            ),
            RaisedButton(
              onPressed: () {
                if(_key.currentState.validate()){
                  _key.currentState.save();
                  _makeLoginPostRequest();
                }else{
                  _autoValidator = true;
                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              padding: const EdgeInsets.all(0.0),
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Colors.blueAccent, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 88.0, minHeight: 48.0),
                  // min sizes for Material buttons
                  alignment: Alignment.center,
                  child: const Text(
                    'LOGIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17.0, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  changePasswordVisibility() {
    debugPrint("Password visibility changed");
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.length < 8)
      return 'Enter valid password greater than 8 digit';
    else
      return null;
  }

  Icon getVisibilityIcon() {
    if (obscurePassword)
      return Icon(
        Icons.visibility,
        color: Colors.black54,
      );
    else
      return Icon(
        Icons.visibility_off,
        color: Colors.black54,
      );
  }

  _makeLoginPostRequest() async {
    HttpWithMiddleware httpClient = HttpWithMiddleware.build(middlewares: [
      HttpLogger(logLevel: LogLevel.BODY),
    ]);

    //encode password to base64
    var encodedPasswordLatin = Latin1Codec().encode(password);
    var encodedPassword = Base64Codec().encode(encodedPasswordLatin);

    var loginPostData = LoginPostData()
    String url = 'http://202.51.74.148/api/token/create';
    Map<String, String> headers = {"Content-type": "application/json"};
    // set up POST request arguments
    String json = '{"email": "$email", "password": "$encodedPassword"}';
    // make POST request
    Response response = await httpClient.post(url, headers: headers, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;
  }
}
