import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/providers/user_provider.dart';
import 'package:quick_iq/screen/home.dart';
import 'package:quick_iq/screen/level1.dart';
import 'package:quick_iq/screen/level2.dart';

class LevelSelector extends StatefulWidget {
  const LevelSelector({super.key});

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  int _selectedLevelIndex = 0;
  final List<int> _requiredStars = [0, 100, 200];
  @override
  Widget build(BuildContext context) {
    final int _totalScore = Provider.of<UserProvider>(context).totalScore;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 128, 16),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 61, 208, 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: TopClipper(),
                  child: Container(
                    color: const Color.fromARGB(255, 136, 210, 33),
                    height: MediaQuery.of(context).size.height * 0.65,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            // Önceki sayfaya dönme işlemleri burada yapılabilir
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ),
                            );
                          },
                        ),
                        const Text(
                          "QuickIQ",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow),
                            const SizedBox(width: 5),
                            Text(
                              "$_totalScore",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text("Oynamak İstediğiniz Leveli Seçiniz"),
                    // Carousel widget'ını burada oluşturun

                    CarouselSlider(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.6,
                        initialPage: 0, // Başlangıçta görünen sayfa indeksi
                        enableInfiniteScroll: false, // Sonsuz kaydırma
                        reverse: false, // Ters yönde kaydırma
                        autoPlay: false, // Otomatik oynatma
                        enlargeCenterPage: true, // Orta sayfayı büyütme
                        viewportFraction: 0.8, // Görünen sayfa genişliği
                        onPageChanged: (index, reason) => {
                          setState(() => _selectedLevelIndex = index),
                        }, // Sayfa değiştiğinde çalışacak fonksiyon
                      ),
                      items: [
                        // Carousel içeriği burada oluşturulur
                        Column(
                          children: [
                            Image.asset("images/level1.jpeg"),
                            const SizedBox(height: 20),
                            const Text(
                              "Level 1",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "Şekil Eşleştirme Oyunu",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            _totalScore >= _requiredStars[1]
                                ? Image.asset("images/level2.jpeg")
                                : Stack(
                                    children: [
                                      ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                            Colors.red, BlendMode.modulate),
                                        child:
                                            Image.asset("images/level2.jpeg"),
                                      ),
                                      Center(
                                        child: Column(
                                          children: [
                                            const Icon(Icons.lock,
                                                size: 200, color: Colors.grey),
                                            Text(
                                              "${_requiredStars[1]} yıldız gereklidir.",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            const Text(
                              "Level 2",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              "8 Çiftli Hafıza Oyunu",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Minimum ${_requiredStars[1]} yıldız gerekli",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Başla butonunu burada oluşturun
                    ElevatedButton(
                      onPressed:
                          _requiredStars[_selectedLevelIndex] <= _totalScore
                              ? () {
                                  // Başla butonuna tıklanınca yapılacak işlemler burada yapılabilir
                                  if (_selectedLevelIndex == 0) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const Level1(),
                                      ),
                                    );
                                  } else if (_selectedLevelIndex == 1) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const Level2(),
                                      ),
                                    );
                                  }
                                }
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Başla"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
