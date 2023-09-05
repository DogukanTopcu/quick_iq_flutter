import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/screen/home.dart';
import 'package:quick_iq/screen/login.dart';

import 'package:http/http.dart' as http;

import '../providers/user_provider.dart';

class User {
  String username;
  String name;
  String surname;
  String password;
  String gender;
  DateTime birthday;

  User({
    required this.username,
    required this.name,
    required this.surname,
    required this.password,
    required this.gender,
    required this.birthday,
  });
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String localStorageUser = "";
  String authenticatedUserStringify = "";
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  DateTime? selectedDate;
  User newUser = User(
      name: "",
      surname: "",
      username: "",
      password: "",
      gender: "",
      birthday: DateTime.now());
  String _passwordCorrection = "";

  void _sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Şifrenizi yeniden giriniz."),
      ),
    );
  }

  Future<void> _signUp() async {
    // String url = 'http://localhost:2000/api/auth/newUser';
    String url = 'https://quick-iq-server.azurewebsites.net/api/auth/newUser';
    await http
        .post(
          Uri.parse(url),
          body: {
            "name": newUser.name,
            "surname": newUser.surname,
            "username": newUser.username,
            "password": newUser.password,
            "gender": newUser.gender,
            "birthday": newUser.birthday.toString(),
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
              // ignore: avoid_print
              print(value.body),
              if (value.statusCode == 200)
                {
                  localStorageUser = value.body,

                  // Load and save user in localstorage and user provider.
                  Provider.of<UserProvider>(context, listen: false)
                      .loginAndSaveUser(
                          jsonDecode(localStorageUser), newUser.password),

                  // Load and save bot in localstorage and bot provider.
                  Provider.of<UserProvider>(context, listen: false)
                      .loadBot(jsonDecode(localStorageUser)["id"]),

                  // Change the scene.
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Home()))
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Kayıt olma işlemi başarısız oldu."),
                    ),
                  )
                }
            })
        .catchError((error) => {
              debugPrint(error),
            });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate != null ? selectedDate! : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        newUser.birthday = picked;
      });
    }
  }

  void _showContractDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context); // Pop-up ekranı kapat
                    },
                  ),
                ],
              ),
              const Text(
                "Sözleşme Metni",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Burada sözleşme metni yer alacak...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFD6306F),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
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
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('../../images/content/sign_up_image.png',
                          width: 150),
                      const Text(
                        "Bize Katıl",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: newUser.name,
                          onChanged: (value) {
                            setState(() {
                              newUser.name = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black), // Text color
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // Inside color
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Adın",
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1), // Border color
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: newUser.surname,
                          onChanged: (value) {
                            setState(() {
                              newUser.surname = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black), // Text color
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // Inside color
                            prefixIcon: const Icon(Icons.person),
                            hintText: "Soyadın",
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1), // Border color
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            _selectDate(context); // Show date picker
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // Inside color
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1), // Border color
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 10),
                                // ignore: unnecessary_null_comparison
                                Text(
                                  selectedDate != null
                                      ? "${selectedDate!.toLocal()}"
                                          .split(' ')[0]
                                      : "Doğum Tarihin", // Display selected date
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Cinsiyetin",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: "Erkek",
                                  groupValue: newUser.gender,
                                  onChanged: (value) {
                                    setState(() {
                                      newUser.gender = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  "Erkek",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                Radio<String>(
                                  value: "Kadın",
                                  groupValue: newUser.gender,
                                  onChanged: (value) {
                                    setState(() {
                                      newUser.gender = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  "Kadın",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: newUser.username,
                          onChanged: (value) {
                            setState(() {
                              newUser.username = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black), // Text color
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // Inside color
                            prefixIcon: const Icon(Icons.person_4),
                            hintText: "Kullanıcı Adın",
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1), // Border color
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          obscureText: _obscurePassword,
                          initialValue: newUser.password,
                          onChanged: (value) {
                            setState(() {
                              newUser.password = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black), // Text color
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // Inside color
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Şifreni Gir",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                            ),
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1), // Border color
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              _passwordCorrection = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black), // Text color
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // Inside color
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Şifreni Yeniden Gir",
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1), // Border color
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value!;
                                });
                              },
                            ),
                            InkWell(
                              onTap: () {
                                _showContractDialog();
                              },
                              child: const Text(
                                "Sözleşme Metni",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const Text("ni Okudum, Onaylıyorum"),
                          ],
                        ),
                        ElevatedButton(
                          // ignore: unrelated_type_equality_checks
                          onPressed: _agreedToTerms &&
                                  newUser.name != "" &&
                                  newUser.surname != "" &&
                                  newUser.username != "" &&
                                  newUser.gender != "" &&
                                  newUser.password != "" &&
                                  selectedDate != null &&
                                  _passwordCorrection != ""
                              ? () => {
                                    if (newUser.password == _passwordCorrection)
                                      {_signUp()}
                                    else
                                      {_sendMessage()}
                                  }
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
                                child: Text("Kayıt Ol",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Zaten bir hesabınız var mı?"),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        child: const Text(
                          "Giriş Yap",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "© 2023 WORMACH",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
