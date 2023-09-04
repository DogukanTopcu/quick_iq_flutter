import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_iq/providers/bot_provider.dart';
import 'package:quick_iq/providers/user_provider.dart';
import 'package:quick_iq/screen/splash.dart';

void main() => runApp(ChangeNotifierProvider<UserProvider>(
    create: (BuildContext context) => UserProvider(),
    child: ChangeNotifierProvider<BotProvider>(
      create: (BuildContext context) => BotProvider(),
      child: const MyApp(),
    )));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Quick IQ",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Splash(),
      );
}
