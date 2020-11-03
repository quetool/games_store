import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:games_store/bloc/games_bloc.dart';
import 'package:games_store/bloc/provider.dart';
import 'package:games_store/components/games_list_components.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:rawg_sdk_dart/core/game.dart';

class GameDetailsScreen extends StatefulWidget {
  const GameDetailsScreen({
    Key key,
  }) : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GamesState>(
      stream: Provider.gamesBlocOf(context).streamGamesSate,
      initialData: GamesState(),
      builder: (BuildContext context, AsyncSnapshot<GamesState> snapshot) {
        var selectedGame = snapshot.data.selectedGame;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              (selectedGame != null) ? selectedGame.name : 'Loading game...',
            ),
            leading: Container(width: 0.0, height: 0.0),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: (!snapshot.hasData || selectedGame == null)
              ? const Center(
                  child: LoaderAnimated(),
                )
              : DetailsBody(selectedGame: selectedGame),
        );
      },
    );
  }
}

class DetailsBody extends StatefulWidget {
  const DetailsBody({
    Key key,
    @required this.selectedGame,
  }) : super(key: key);

  final Game selectedGame;

  @override
  _DetailsBodyState createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  Game _selectedGame;
  final List<Screenshot> _screenShots = [];
  final _controller = PageController();

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.selectedGame;
    _screenShots.add(
      Screenshot()
        ..id = -1
        ..image = _selectedGame.backgroundImage,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.gamesBlocOf(context).getGameScreenshots(_selectedGame.slug);
    Provider.gamesBlocOf(context).streamGamesSate.listen((GamesState data) {
      if (!mounted) return;
      if (data == null ||
          data.selectedGame == null ||
          (data.selectedGame.shortScreenshots ?? <dynamic>[]).isEmpty) return;
      _selectedGame = data.selectedGame;
      print(_selectedGame.shortScreenshots.length);
      _screenShots.addAll((_selectedGame.shortScreenshots as List<Screenshot>));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Card(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      child: AspectRatio(
                        aspectRatio: 2560 / 1440,
                        child: PageIndicatorContainer(
                          length: _screenShots.length,
                          indicatorColor: Colors.grey,
                          indicatorSelectorColor:
                              ThemeData.dark().indicatorColor,
                          shape: IndicatorShape.circle(size: 8.0),
                          child: PageView.builder(
                            controller: _controller,
                            itemBuilder: (BuildContext context, int index) {
                              return CachedNetworkImage(
                                imageUrl: _screenShots[index].image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return Image.asset(
                                    'assets/placeholder.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                            itemCount: _screenShots.length,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 100.0,
                        color: Colors.yellow,
                      ),
                    ],
                  )
                ],
              ),
              Container(
                height: kToolbarHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                      child: Chip(
                        label: Text(
                          _selectedGame.platforms[index].platform.name,
                        ),
                      ),
                    );
                  },
                  itemCount: _selectedGame.platforms.length,
                ),
              ),
              Card(
                elevation: 0.0,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_selectedGame.descriptionRaw),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
