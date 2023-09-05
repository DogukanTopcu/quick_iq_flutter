import 'package:flutter/material.dart';
import 'package:quick_iq/screen/login.dart';
import 'package:quick_iq/screen/signUp.dart';

void main() {
  runApp(const Register());
}

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(93, 23, 236, 1),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: const Color.fromRGBO(93, 23, 236, 1),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: TopClipper(),
                    child: Container(
                      color: const Color.fromRGBO(109, 46, 239, 1),
                      height: height * 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              // ignore: avoid_unnecessary_containers
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Image.asset(
                            'images/content/quickIq_logo.png',
                            height: 150,
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "Hoş Geldiniz",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          const Text(
                            "QuickIQ",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        image: DecorationImage(
                          image: Image.asset('images/content/register.png',
                                  width: 300)
                              .image,
                          // fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUp()));
                            },
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 50);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 50);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
