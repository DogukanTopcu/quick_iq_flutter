import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/providers/user_provider.dart';
import 'package:quick_iq/screen/home.dart';
import 'package:quick_iq/screen/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<bool> _login(username, pass) async {
    String url = 'http://localhost:2000/api/auth/login';
    await http.post(
      Uri.parse(url),
      body: {'username': username, 'password': pass},
      headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
            "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
      },
    ).then((value) {
      if (value.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
    return false;
  }

  _navigateToHome() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _user = _prefs.getString("user") ?? "no user";
    String _pass = _prefs.getString("password") ?? "no password";

    if (_user == "no user") {
      await Future.delayed(const Duration(milliseconds: 3000), () {});
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Register()));
    } else {
      var localUser = jsonDecode(_user);

      if (await _login(localUser["username"], _pass) != false) {
        await Future.delayed(const Duration(milliseconds: 3000), () {});
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Register()));
      } else {
        await Future.delayed(const Duration(milliseconds: 3000), () {});
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false)
            .loginAndSaveUser(localUser, _pass);

        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false)
            .loadBot(localUser["id"]);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(86, 139, 87, 1),
      body: Center(
          child: Column(
        children: <Widget>[
          SizedBox(height: 60),
          Image(image: AssetImage("../../images/wormac.png"), width: 200),
          SizedBox(height: 15),
          Text(
            "WORMAC#",
            style: TextStyle(
                color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
          ),
          Text(
            "Quick IQ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 90,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 80),
          Text(
            "Created by:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Utku Kara",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Doğukan Topçu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Gökhan Karahanoğulları",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Arjin Budak",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )),

      // body: const Column(children: <Widget>[
      //   Align(alignment: Alignment.center),
      //   Image(image: AssetImage("../../images/wormac.png"), width: 250),
      //   Text(
      //     "Quick IQ",
      //     style: TextStyle(
      //         color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      //   ),
      // ]),
    );
  }
}
