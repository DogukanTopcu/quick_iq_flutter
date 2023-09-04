import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/providers/user_provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:quick_iq/screen/levelSelector.dart';

class Level2Object {
  int userId;
  List<String> allImages;
  String firstOption;
  String secondOption;
  bool isCorrect;
  int time;

  Level2Object(this.userId, this.allImages, this.firstOption, this.secondOption,
      this.isCorrect, this.time);
}

class Level2 extends StatefulWidget {
  const Level2({super.key});

  @override
  State<Level2> createState() => _Level2State();
}

class _Level2State extends State<Level2> {
  final Level2Object _level2Object = Level2Object(0, [], "", "", false, 0);
  int timepass = 0;

  final List<String> _imagePaths = [
    '../../images/apple.png',
    '../../images/berry.png',
    '../../images/bomb.png',
    '../../images/bread.png',
    '../../images/cheese.png',
    '../../images/crown.png',
    '../../images/meat1.png',
    '../../images/meat2.png',
  ];

  List<String> _cardImages = [];
  List<int> _flippedImages = [];
  List<bool> _cardFlips = [];
  int _firstCardIndex = -1;
  int _secondCardIndex = -1;
  bool _isGameStart = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() async {
    _level2Object.allImages = _imagePaths;

    _imagePaths.shuffle();
    _cardImages.clear();
    _cardFlips.clear();

    _imagePaths.forEach((path) {
      _cardImages.add(path);
      _cardImages.add(path);
    });

    setState(() {
      _cardImages.shuffle();
      _cardFlips = List.generate(_cardImages.length, (index) => true);
    });
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _cardFlips = List.generate(_cardImages.length, (index) => false);
      _isGameStart = true;
    });
    _startTimer();
  }

  void _startTimer() {
    timepass = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondCardIndex == -1) {
        setState(() {
          timepass++;
        });
      } else {
        _level2Object.time = timepass;
        timepass = 0;
      }
    });
  }

  void _flipCard(int index) {
    setState(() {
      if (_firstCardIndex == -1) {
        _firstCardIndex = index;
        _cardFlips[_firstCardIndex] = true; // İlk kartı çevir
        _level2Object.firstOption = _cardImages[_firstCardIndex];
      } else if (_secondCardIndex == -1) {
        _secondCardIndex = index;
        _cardFlips[_secondCardIndex] = true; // İkinci kartı çevir
        _level2Object.secondOption = _cardImages[_secondCardIndex];

        // Eğer seçilen iki kart aynıysa
        if (_cardImages[_firstCardIndex] == _cardImages[_secondCardIndex]) {
          _flippedImages.add(_firstCardIndex);
          _flippedImages.add(_secondCardIndex);
          Provider.of<UserProvider>(context, listen: false)
              .incrementTotalScore(10);
          _level2Object.isCorrect = true;
          _firstCardIndex = -1; // Seçili kartları sıfırla
          _secondCardIndex = -1;
        } else {
          // Seçili kartlar aynı değilse, kartları geri çevir
          _level2Object.isCorrect = false;
          Future.delayed(const Duration(seconds: 1)).then((vlaue) {
            setState(() {
              _cardFlips[_firstCardIndex] = false;
              _cardFlips[_secondCardIndex] = false;
              _firstCardIndex = -1; // Seçili kartları sıfırla
              _secondCardIndex = -1;
            });
          });
        }
        _sendData();
      }
    });
  }

  Future<void> _sendData() async {
    String url = "http://localhost:2000/api/game/level2/addData";
    http.post(
      Uri.parse(url),
      body: {
        "userId": _level2Object.userId.toString(),
        "allImages": _level2Object.allImages.toString(),
        "firstOption": _level2Object.firstOption,
        "secondOption": _level2Object.secondOption,
        "isCorrect": _level2Object.isCorrect.toString(),
        "time": _level2Object.time.toString(),
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

  @override
  Widget build(BuildContext context) {
    int _score = Provider.of<UserProvider>(context).totalScore;
    _level2Object.userId = Provider.of<UserProvider>(context, listen: false).id;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 95, 238),
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            color: Color.fromARGB(255, 23, 176, 236),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipPath(
                clipper: TopClipper(),
                child: Container(
                  color: Color.fromARGB(255, 46, 187, 239),
                  height: MediaQuery.of(context).size.height * 0.65,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: MediaQuery.of(context).size.width > 500
                        ? const EdgeInsets.fromLTRB(40, 0, 40, 0)
                        : const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (!_flippedImages.contains(index) &&
                              _firstCardIndex != index &&
                              _isGameStart) {
                            _flipCard(index);
                          }
                        },
                        child: Card(
                          child: _cardFlips[index]
                              ? Image.asset(_cardImages[index])
                              : Image.asset('../../images/wormac.png'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const Text(
                        "Harikasın",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _flippedImages.length == 16
                            ? () {
                                setState(() {
                                  _cardImages = [];
                                  _flippedImages = [];
                                  _cardFlips = [];
                                  _firstCardIndex = -1;
                                  _secondCardIndex = -1;
                                  _isGameStart = false;
                                  timepass = 0;
                                });
                                _initializeGame();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Yeniden Başlat"),
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
