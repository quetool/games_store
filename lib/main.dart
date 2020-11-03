import 'package:flutter/material.dart';
import 'package:games_store/bloc/provider.dart';
import 'package:games_store/screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final appName = 'Game Store';

  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        title: appName,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.grey,
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          cardTheme: const CardTheme(
            elevation: 6.0,
            shadowColor: Colors.black,
          ),
        ),
        home: HomeScreen(title: appName),
      ),
    );
  }
}
