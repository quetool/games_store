import 'package:flutter/material.dart';
import 'package:games_store/bloc/games_bloc.dart';
import 'package:games_store/bloc/provider.dart';
import 'package:games_store/components/games_list_components.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GamesState gamesState;
  final _nestedController = ScrollController();

  @override
  void initState() {
    super.initState();
    gamesState = GamesState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.gamesBlocOf(context).loadGamesWithPagination();
    Provider.gamesBlocOf(context).getTopTenGames();
    Provider.gamesBlocOf(context).streamGamesSate.listen((GamesState data) {
      if (!mounted) return;
      if (data == null) return;
      gamesState = data;
    });
  }

  void _loadMoreItems() {
    print('reach the bottom');
    Provider.gamesBlocOf(context)
        .loadGamesWithPagination(nextPageUrl: gamesState.gamesListNextPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<GamesState>(
          stream: Provider.gamesBlocOf(context).streamGamesSate,
          builder: (BuildContext context, AsyncSnapshot<GamesState> snapshot) {
            if (snapshot.data == null) {
              return Container(width: 0.0, height: 0.0);
            }
            return SafeArea(
              bottom: false,
              child: OrientationBuilder(builder: (context, orientation) {
                return NestedScrollView(
                  controller: _nestedController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const ListSeparator(
                              title: 'Top 10 Games',
                            ),
                            TopTenBanner(
                              topTenGamesList: snapshot.data.topTenGamesList,
                              orientation: orientation,
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          const ListSeparator(title: 'All Games'),
                          SearchField(
                            onTap: () {
                              _nestedController.animateTo(
                                200.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.linear,
                              );
                            },
                            onSubmitted: (text) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              Provider.gamesBlocOf(context).searchGames(text);
                            },
                          ),
                          Expanded(
                            child: NotificationListener(
                              onNotification:
                                  (ScrollNotification notification) {
                                if (notification is ScrollEndNotification) {
                                  if (notification.metrics.atEdge &&
                                      notification.metrics.pixels >=
                                          MediaQuery.of(context).size.height) {
                                    _loadMoreItems();
                                  }
                                }
                                return true;
                              },
                              child: GridView.builder(
                                shrinkWrap: true,
                                primary: true,
                                padding: const EdgeInsets.only(
                                  top: 6.0,
                                  left: 12.0,
                                  bottom: 30.0,
                                ),
                                gridDelegate:
                                    // ignore: lines_longer_than_80_chars
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (orientation == Orientation.portrait)
                                          ? 2
                                          : 4,
                                  childAspectRatio: 1.1,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  var game = snapshot.data.gamesList[index];
                                  return GameListItem(game: game);
                                },
                                itemCount: snapshot.data.gamesList.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                      (!snapshot.hasData || snapshot.data.loadingGames)
                          ? const Center(
                              child: LoaderAnimated(),
                            )
                          : Container(width: 0.0, height: 0.0),
                    ],
                  ),
                );
              }),
            );
          }),
    );
  }
}
