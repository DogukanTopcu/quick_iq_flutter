import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/screen/home.dart';
import 'package:quick_iq/screen/signUp.dart';
import 'package:http/http.dart' as http;

import '../providers/user_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class User {
  String useName;
  String password;

  User({
    required this.useName,
    required this.password,
  });
}

class _LoginState extends State<Login> {
  String localStorageUser = "";
  bool _obscurePassword = true;
  String _username = "";
  String _password = "";

  Future<void> _login() async {
    String url = 'http://localhost:2000/api/auth/login';
    await http
        .post(
          Uri.parse(url),
          body: {
            "username": _username,
            "password": _password,
          },
          headers: {
            "Accept": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers":
                "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
          },
        )
        .then((value) => {
              if (value.statusCode == 200)
                {
                  localStorageUser = value.body,

                  // Load and save user in localstorage and user provider.
                  Provider.of<UserProvider>(context, listen: false)
                      .loginAndSaveUser(
                          jsonDecode(localStorageUser), _password),

                  // Load and save bot in localstorage and bot provider.
                  Provider.of<UserProvider>(context, listen: false)
                      .loadBot(jsonDecode(localStorageUser)["id"]),

                  // Change the scene.
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Home()))
                }
              else if (value.statusCode == 404)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kullanıcı bulunamadı"),
                    ),
                  )
                }
              else if (value.statusCode == 400)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Hatalı Kullanıcı Adı veya Şifre"),
                    ),
                  )
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bilinmeyen bir hata oluştu"),
                    ),
                  )
                }
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Bilinmeyen bir hata oluştu"),
                ),
              )
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 169, 103),
      body: Center(
        child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hoş Geldiniz",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          "QuickIQ",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    Image.asset('../../images/content/quickIq_logo.png',
                        width: 80),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image(
                        image:
                            AssetImage("../../images/content/login_image.png"),
                        width: 150),
                    Text("Merhaba :)",
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                        },
                        style:
                            const TextStyle(color: Colors.black), // Text color
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white, // Inside color
                          prefixIcon: const Icon(Icons.person_4),
                          hintText: "Kullanıcı Adın",
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1), // Border color
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                        style:
                            const TextStyle(color: Colors.black), // Text color
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white, // Inside color
                          prefixIcon: const Icon(Icons.lock),
                          hintText: "Şifren",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1), // Border color
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _username != "" && _password != ""
                            ? () => _login()
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: const Center(
                              child: Text("Giriş Yap",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ))),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Buralarda yeni misin?"),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUp()));
                            },
                            child: const Text(
                              "Kayıt Ol",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "© 2023 WORMACH",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            )),
      ),
    );
  }
}
