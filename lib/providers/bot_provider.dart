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
    "botMessage": "",
    "userMessage": "",
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
    await http.post(Uri.parse(url), body: {"botId": id.toString()}).then((res) {
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        conversations = response["data"];
      }
    });
    notifyListeners();
  }

  Future<void> generateText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString("user") ?? "no user";
    String name = "";
    if (user != "no user") {
      name = jsonDecode(user)["name"];
    }

    String url = "http://localhost:2000/api/bot/generateText";
    await http.post(Uri.parse(url), body: {
      "name": name,
      "elderConversations": conversations.toString()
    }).then((res) {
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        text = response["data"];
        speak(text);
        saveConversation["botMessage"] = text;
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
    await flutterTextToSpeech.setSpeechRate(1.2);

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

  void generateResponse(String userText) {
    // Save Conversation
    saveConversation["userMessage"] = userText;
    savingConversation();

    // Response
    text = "";
    text = "Tanıştığımıza çok memnun oldum.";
    speak(text);
    saveConversation["botMessage"] = text;
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
    await http.post(Uri.parse(url), body: {
      "botId": saveConversation["botId"].toString(),
      "userId": saveConversation["userId"].toString(),
      "botMessage": saveConversation["botMessage"],
      "userMessage": saveConversation["userMessage"],
      "type": saveConversation["type"]
    }).then((res) {
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        print(response);
        print(response["message"]);
      }
    });
    conversations.add(saveConversation);
    saveConversation = {
      "userId": 0,
      "botId": 0,
      "botMessage": "",
      "userMessage": "",
      "type": "",
    };
    notifyListeners();
  }
}
