import "package:avatar_glow/avatar_glow.dart";
import "package:flutter/material.dart";
import "package:flutter_tts/flutter_tts.dart";
import "package:percent_indicator/circular_percent_indicator.dart";
import "package:provider/provider.dart";
import "package:quick_iq/providers/bot_provider.dart";
import "package:quick_iq/providers/user_provider.dart";
import "package:quick_iq/screen/levelSelector.dart";
import "package:quick_iq/screen/register.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:speech_to_text/speech_to_text.dart";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  SpeechToText speech = SpeechToText();
  final FlutterTts flutterTextToSpeech = FlutterTts();
  var isListening = false;
  String text = "";

  @override
  void initState() {
    super.initState();
    Provider.of<BotProvider>(context, listen: false).generateText();
  }

  @override
  Widget build(BuildContext context) {
    int _currentLevel = Provider.of<UserProvider>(context).getCurrentLevel();
    double _percentage = Provider.of<UserProvider>(context).percent();

    text = Provider.of<BotProvider>(context, listen: true).text;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 147, 23),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(253, 164, 26, 1),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: TopClipper(),
                  child: Container(
                    color: const Color.fromRGBO(236, 150, 18, 1),
                    height: MediaQuery.of(context).size.height * 0.55,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              "QuickIQ",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'customize') {
                              // Özelleştir butonuna basıldığında yapılacak işlem
                            } else if (value == 'logout') {
                              // Provider.of<BotProvider>(context, listen: false)
                              //     .stopSpeaking();
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.remove("user");
                              prefs.remove("password");
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'customize',
                                child: Text('Özelleştir'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Text('Çıkış Yap'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AvatarGlow(
                          endRadius: 50.0,
                          animate: isListening,
                          glowColor: Colors.white,
                          duration: const Duration(milliseconds: 2000),
                          repeat: true,
                          repeatPauseDuration:
                              const Duration(milliseconds: 100),
                          showTwoGlows: true,
                          child: GestureDetector(
                            onTap: () async {
                              if (isListening) {
                                await speech.cancel();
                                // ignore: use_build_context_synchronously
                                Provider.of<BotProvider>(context, listen: false)
                                    .generateResponse(text);
                              } else {
                                if (await speech.initialize()) {
                                  // ignore: use_build_context_synchronously
                                  // await Provider.of<BotProvider>(context,
                                  //         listen: false)
                                  //     .stopSpeaking();
                                  speech.listen(
                                    listenMode: ListenMode.dictation,
                                    localeId: "tr-TR",
                                    onResult: (result) {
                                      Provider.of<BotProvider>(context,
                                              listen: false)
                                          .listen(result.recognizedWords);
                                    },
                                  );
                                }
                              }
                              setState(() {
                                isListening = !isListening;
                              });
                            },
                            child: Image(
                              image: const AssetImage(
                                  '../../images/content/bot_image.png'),
                              width: isListening ? 50 : 70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          width: MediaQuery.of(context).size.width > 450
                              ? 450 / 1.5
                              : MediaQuery.of(context).size.width / 1.5,
                          child: Text(text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isListening
                                      ? Colors.black87
                                      : Colors.black54)),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Provider.of<BotProvider>(context, listen: false)
                        //     .stopSpeaking();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LevelSelector(),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width > 450
                            ? 450 / 2
                            : MediaQuery.of(context).size.width / 2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              '../../images/content/PlayButton.png',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 15,
                          backgroundColor: Color.fromARGB(94, 255, 34, 34),
                          progressColor: Colors.deepPurpleAccent,
                          percent: _percentage,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Text(
                            "Level $_currentLevel",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
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
