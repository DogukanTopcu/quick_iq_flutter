import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_iq/providers/bot_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  bool isLoggedIn = false;
  int id = 0;
  String username = '';
  String password = "";
  String name = "";
  String surname = "";
  int totalScore = 10;
  String gender = "";
  int botId = 0;
  String birthday = "";
  String registerDate = "";

  final List<int> _requiredStars = [0, 100, 200, 400, 800, 1600, 10000000];
  int currentLevel = 0;
  double percentage = 0;

  void logout(String username, String password) {
    isLoggedIn = false;
    username = '';
    notifyListeners();
  }

  Future<void> loginAndSaveUser(user, password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(user));
    await prefs.setString("password", password);

    isLoggedIn = true;
    username = user["username"];
    name = user["name"];
    surname = user["surname"];
    totalScore = user["totalscore"];
    botId = user["botId"];
    birthday = user["birthday"];
    registerDate = user["registerDate"] ?? "";
    gender = user["gender"];
    password = password;
    id = user["id"];
    notifyListeners();
  }

  void signUp(user) {
    isLoggedIn = true;
    username = user["username"];
    name = user["name"];
    surname = user["surname"];
    totalScore = user["totalScore"];
    botId = user["botId"];
    birthday = user["birthday"];
    registerDate = user["registerdDate"];
    notifyListeners();
  }

  void incrementTotalScore(int addScore) async {
    totalScore += addScore;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getUser = await prefs.getString("user");
    var user = jsonDecode(getUser!);
    user["totalscore"] = totalScore;
    await prefs.setString("user", jsonEncode(user));

    incrementInDatabase(user, totalScore);

    notifyListeners();
  }

  Future<void> incrementInDatabase(user, score) async {
    // String url = "http://localhost:2000/api/game/score/increase";
    String url =
        "https://quick-iq-server.azurewebsites.net/api/game/score/increase";
    await http.post(
      Uri.parse(url),
      body: {
        "userId": user["id"].toString(),
        "score": score.toString(),
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

  int getCurrentLevel() {
    for (int i = 0; i < _requiredStars.length; i++) {
      if (totalScore >= _requiredStars[i]) {
        currentLevel = i + 1;
      }
    }
    return currentLevel;
  }

  double percent() {
    int currentLevelScore =
        _requiredStars[currentLevel == 0 ? currentLevel : currentLevel - 1];
    int nextLevelScore =
        _requiredStars[currentLevel == 0 ? currentLevel + 1 : currentLevel];
    int difference = nextLevelScore - currentLevelScore;
    int currentScore = totalScore - currentLevelScore;
    percentage = currentScore / difference;
    return percentage;
  }

  Future<void> loadBot(int id) async {
    // String url = "http://localhost:2000/api/bot/callAssistant";
    String url =
        "https://quick-iq-server.azurewebsites.net/api/bot/callAssistant";
    await http.post(Uri.parse(url), body: {
      "userId": id.toString(),
    }, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers":
          "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
    }).then(
      (response) {
        BotProvider botProvider = BotProvider();
        botProvider.loadBot(response.body);
      },
    );
    notifyListeners();
  }
}
