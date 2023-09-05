import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/providers/user_provider.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:quick_iq/screen/levelSelector.dart';

class Level1Object {
  int userId;
  String questionImage;
  List<String> optionImages;
  String userResponse;
  bool isCorrect;
  int time;

  Level1Object(this.userId, this.questionImage, this.optionImages,
      this.userResponse, this.isCorrect, this.time);
}

class Level1 extends StatefulWidget {
  const Level1({super.key});

  @override
  State<Level1> createState() => _Level1State();
}

class _Level1State extends State<Level1> {
  final Level1Object _level1Object = Level1Object(0, "", [], "", false, 0);
  int timepass = 0;

  final List<String> _shapes = [
    '../../images/apple.png',
    '../../images/berry.png',
    '../../images/bomb.png',
    '../../images/bread.png',
    '../../images/cheese.png',
    '../../images/crown.png',
    '../../images/meat1.png',
    '../../images/meat2.png',
  ];
  List<String> _choices = [];
  String? _currentShape;
  String? _selectedShape;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _showControlButton = false;
  bool _showContinueButton = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _changeShape();
  }

  void _startTimer() {
    timepass = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_showResult) {
        setState(() {
          timepass++;
        });
      } else {
        _level1Object.time = timepass;
        timepass = 0;
      }
    });
  }

  void _changeShape() {
    setState(() {
      _currentShape = _shapes[Random().nextInt(_shapes.length)];
      _selectedShape = null;
      _showResult = false;
      _showContinueButton = false;
      _choices = _generateChoices();

      _level1Object.questionImage = _currentShape!;
    });
  }

  List<String> _generateChoices() {
    _shapes.shuffle();
    List<String> choices = [_currentShape!];
    while (choices.length < 4) {
      String randomShape = _shapes[Random().nextInt(_shapes.length)];
      if (!choices.contains(randomShape)) {
        choices.add(randomShape);
        _level1Object.optionImages.add(randomShape);
      }
    }
    choices.shuffle();
    return choices;
  }

  void _checkAnswer(String answer) {
    _level1Object.userResponse = answer;
    setState(() {
      if (answer == _currentShape) {
        _isCorrect = true;
        _level1Object.isCorrect = true;
        Provider.of<UserProvider>(context, listen: false)
            .incrementTotalScore(5);
      } else {
        _level1Object.isCorrect = false;
      }
      _showResult = true;
      _showContinueButton = true;
    });
  }

  void _continue() {
    setState(() {
      _isCorrect = false;
      _showResult = false;
      _showContinueButton = false;
      _selectedShape = null;
      _showControlButton = false;
    });
    _sendData();
    _changeShape();
  }

  // EXIT GAME
  Future<void> _showExitDialog() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Çıkmak İstediğinize Emin Misiniz?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Evet seçeneği
              },
              child: const Text("Evet"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Hayır seçeneği
              },
              child: const Text("Hayır"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LevelSelector(),
        ),
      );
    }
  }

  Future<void> _sendData() async {
    // String url = "http://localhost:2000/api/game/level1/addData";
    String url =
        "https://quick-iq-server.azurewebsites.net/api/game/level1/addData";
    http.post(
      Uri.parse(url),
      body: {
        "userId": _level1Object.userId.toString(),
        "questionImage": _level1Object.questionImage,
        "optionImages": _level1Object.optionImages.toString(),
        "userResponse": _level1Object.userResponse,
        "isCorrect": _level1Object.isCorrect.toString(),
        "time": _level1Object.time.toString(),
      },
      headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
            "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _level1Object.userId = Provider.of<UserProvider>(context).id;
    int _score = Provider.of<UserProvider>(context).totalScore;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 95, 238),
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            color: const Color.fromRGBO(93, 23, 236, 1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: TopClipper(),
                child: Container(
                  color: const Color.fromRGBO(109, 46, 239, 1),
                  height: MediaQuery.of(context).size.height * 0.65,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: _showExitDialog,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow),
                            const SizedBox(width: 5),
                            Text(
                              "$_score",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    _currentShape!,
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: MediaQuery.of(context).size.width > 500
                        ? const EdgeInsets.fromLTRB(40, 0, 40, 0)
                        : const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _choices.length,
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        onPressed: _showContinueButton
                            ? _selectedShape == _choices[index]
                                ? () {}
                                : null
                            : () {
                                setState(() {
                                  _selectedShape = _choices[index];
                                  _showControlButton = true;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showContinueButton
                              ? _isCorrect
                                  ? Colors.green
                                  : Colors.red
                              : _selectedShape == _choices[index]
                                  ? const Color.fromARGB(255, 76, 97, 175)
                                  : const Color.fromARGB(246, 149, 190, 223),
                          maximumSize: const Size(double.infinity, 100),
                        ),
                        child: Image.asset(_choices[index]),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        _showResult
                            ? _isCorrect
                                ? "Tebrikler, doğru eşleşti!"
                                : "Üzgünüm, verdiğin cevap yanlış!"
                            : "",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showControlButton
                            ? _showContinueButton
                                ? _continue
                                : () {
                                    _checkAnswer(_selectedShape!);
                                  }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showContinueButton
                              ? _isCorrect
                                  ? Colors.green
                                  : Colors.red
                              : Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                            _showContinueButton ? "Devam Et" : "Kontrol Et"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
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
