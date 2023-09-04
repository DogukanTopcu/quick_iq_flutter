import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class BotProvider with ChangeNotifier {
  int id = 0;
  int userId = 0;
  String image = "";
  List<dynamic> conversations = [];

  FlutterTts flutterTextToSpeech = FlutterTts();
  String text = "";

  var saveConversation = {
    "userId": 0,
    "botId": 0,
    "bot_message": "",
    "user_message": "",
    "type": "",
  };

  void loadBot(bot) async {
    var decodeBot = jsonDecode(bot);
    id = decodeBot["id"];
    userId = decodeBot["userId"];
    image = decodeBot["image"];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("bot", jsonEncode(bot));

    loadConversations();
    notifyListeners();
  }

  Future<void> loadConversations() async {
    String url = "http://localhost:2000/api/bot/getConversations";
    await http
        .post(Uri.parse(url), body: {"botId": id.toString()}).then((res) async {
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        conversations.add(jsonEncode(response["data"]));

        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString("conversations", jsonEncode(response["data"]));
      }
    });
    notifyListeners();
  }

  Future<void> generateText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("user") ?? "no user";
    String conversations = prefs.getString("conversations") ?? "[]";
    String name = "";
    if (user != "no user") {
      name = jsonDecode(user)["name"];
    }

    String url = "http://localhost:2000/api/bot/generateText";
    await http.post(
      Uri.parse(url),
      body: {
        "name": name,
        "elderConversations": conversations,
        "mode": "first"
      },
      headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
            "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
      },
    ).then((res) {
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        text = response["data"];
        speak(text);
        saveConversation["bot_message"] = text;
        saveConversation["type"] = "initial";
      }
    });
    notifyListeners();
  }

  Future<void> speak(String text) async {
    // Settings
    FlutterTts flutterTextToSpeech = FlutterTts();
    await flutterTextToSpeech.setLanguage("tr-TR");
    await flutterTextToSpeech.setPitch(1.5);
    await flutterTextToSpeech.setSpeechRate(1.1);

    await flutterTextToSpeech.setVoice({
      "name": "Microsoft Emel Online (Natural) - Turkish (Turkey)",
      "locale": "tr-TR"
    });
    //Man Voice - {name: Microsoft Ahmet Online (Natural) - Turkish (Turkey), locale: tr-TR},
    //Woman Voice - {name: Microsoft Emel Online (Natural) - Turkish (Turkey), locale: tr-TR}

    text = text.replaceAll(".", ",");
    // Speaking
    await flutterTextToSpeech.speak(text);
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    text = "";
    await flutterTextToSpeech.stop();
    notifyListeners();
  }

  Future<void> generateResponse(String userText) async {
    // Save Conversation
    saveConversation["user_message"] = userText;
    await savingConversation();

    // Response
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("user") ?? "no user";
    String conversations = prefs.getString("conversations") ?? "[]";
    String name = "";
    if (user != "no user") {
      name = jsonDecode(user)["name"];
    }

    String url = "http://localhost:2000/api/bot/generateText";
    await http.post(
      Uri.parse(url),
      body: {
        "name": name,
        "elderConversations": conversations,
        "mode": text,
      },
      headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
            "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
      },
    ).then(
      (res) {
        if (res.statusCode == 200) {
          var response = jsonDecode(res.body);
          text = response["data"];
          speak(text);
          saveConversation["bot_message"] = text;
          saveConversation["type"] = "conversation";
        }
      },
    ).catchError((err) {
      print(err);
    });
    notifyListeners();
  }

  void listen(String txt) {
    text = txt;
    notifyListeners();
  }

  Future<void> savingConversation() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String bot = _prefs.getString("bot") ?? "no bot";

    var decodeBot = jsonDecode(jsonDecode(bot));
    saveConversation["botId"] = decodeBot["id"];
    saveConversation["userId"] = decodeBot["userId"];

    String url = "http://localhost:2000/api/bot/addNewConversation";
    await http.post(
      Uri.parse(url),
      body: {
        "botId": saveConversation["botId"].toString(),
        "userId": saveConversation["userId"].toString(),
        "botMessage": saveConversation["bot_message"],
        "userMessage": saveConversation["user_message"],
        "type": saveConversation["type"]
      },
      headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers":
            "Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers",
      },
    );

    String convs = _prefs.getString("conversations") ?? "no conversations";
    if (convs != "no conversations") {
      conversations = jsonDecode(convs);
      conversations.add(saveConversation);
    }
    _prefs.setString("conversations", jsonEncode(conversations));
    saveConversation = {
      "userId": 0,
      "botId": 0,
      "bot_message": "",
      "user_message": "",
      "type": "",
    };
    notifyListeners();
  }
}
