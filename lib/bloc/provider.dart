import 'package:flutter/material.dart';
import 'package:games_store/bloc/games_bloc.dart';

class Provider extends InheritedWidget {
  Provider({Key key, Widget child}) : super(key: key, child: child);

  final gamesBloc = GamesBloc();

  static GamesBloc gamesBlocOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().gamesBloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
