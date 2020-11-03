import 'package:rawg_sdk_dart/core/game.dart';
import 'package:rawg_sdk_dart/rawg_sdk_dart.dart';
import 'package:rxdart/rxdart.dart';

class GamesState {
  bool loadingGames = false;
  List<Game> gamesList = [];
  String gamesListNextPage = '';
  Game selectedGame;
  List<Game> topTenGamesList = [];
  List<Game> cartList = [];
  List<Game> favList = [];
  String error = '';
}

class GamesBloc extends Object {
  final _gamesState = BehaviorSubject<GamesState>();
  Stream<GamesState> get streamGamesSate => _gamesState.stream;
  Function(GamesState) get sinkGamesSate => _gamesState.sink.add;

  final _rawg = RawgApiClient();

  GamesState getCurrentState() {
    var currentState = _gamesState.stream.value;
    currentState ??= GamesState();
    return currentState;
  }

  void loadGamesWithPagination({String nextPageUrl = ''}) async {
    var currentState = getCurrentState()
      ..loadingGames = true
      ..error = '';
    sinkGamesSate(currentState);

    if (nextPageUrl != '') {
      _rawg.requestCustomUrl(nextPageUrl, (error, nextUrl, dynamic objects) {
        print('nextUrl $nextUrl');
        var games = (objects as List<dynamic>)
            .map((dynamic e) => Game.fromJson(e as Map<String, dynamic>))
            .toList();
        var currentState = getCurrentState()
          ..gamesList.addAll(games)
          ..gamesListNextPage = nextUrl
          ..error = error
          ..loadingGames = false;
        sinkGamesSate(currentState);
      });
    } else {
      _rawg.getGames(completion: (error, nextUrl, games) {
        print('nextUrl $nextUrl');
        var currentState = getCurrentState()
          ..gamesList = games
          ..gamesListNextPage = nextUrl
          ..error = error
          ..loadingGames = false;
        sinkGamesSate(currentState);
      });
    }
  }

  void getTopTenGames() {
    _rawg.getTopTenGamesAllTime(completion: (error, games) {
      var currentState = getCurrentState()
        ..topTenGamesList = games
        ..error = error
        ..loadingGames = false;
      sinkGamesSate(currentState);
    });
  }

  void getGameDetails(int gameId) {
    var currentState = getCurrentState()
      ..selectedGame = null
      ..error = '';
    sinkGamesSate(currentState);
    _rawg.getGameDetails('$gameId', (error, gameDetails) {
      print(gameDetails != null ? gameDetails.toJson() : 'NO DATA');
      var currentState = getCurrentState()
        ..selectedGame = gameDetails
        ..error = error;
      sinkGamesSate(currentState);
    });
  }

  void getGameScreenshots(String slug) {
    _rawg.getGameScreenshots(slug, (error, screenshots) {
      var currentState = getCurrentState()
        ..selectedGame.shortScreenshots = screenshots
        ..error = error;
      sinkGamesSate(currentState);
    });
  }

  void searchGames(String text) {
    if (text == '') return;
    var currentState = getCurrentState()
      ..loadingGames = true
      ..error = '';
    sinkGamesSate(currentState);

    _rawg.getGames(
        moreParams: {'search': text},
        completion: (error, nextUrl, games) {
          print('nextUrl $nextUrl');
          var currentState = getCurrentState()
            ..gamesList = games
            ..gamesListNextPage = nextUrl
            ..error = error
            ..loadingGames = false;
          sinkGamesSate(currentState);
        });
  }

  void dispose() {
    _gamesState.close();
  }
}
