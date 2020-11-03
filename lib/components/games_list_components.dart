import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:games_store/bloc/provider.dart';
import 'package:games_store/helpers/helpers.dart';
import 'package:games_store/screens/game_details.dart';
import 'package:rawg_sdk_dart/core/game.dart';

class ListSeparator extends StatelessWidget {
  const ListSeparator({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white38,
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  const GameListItem({
    Key key,
    @required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      openColor: Colors.transparent,
      openElevation: 0.0,
      tappable: false,
      openBuilder:
          (BuildContext context, Function({Object returnValue}) action) {
        return const GameDetailsScreen();
      },
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      closedBuilder: (BuildContext context, void Function() action) {
        return GestureDetector(
          onTap: () {
            Provider.gamesBlocOf(context).getGameDetails(game.id);
            action();
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0, right: 12.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 2560 / 1414,
                    child: CachedNetworkImage(
                      imageUrl: game.backgroundImage ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Image.asset(
                          'assets/placeholder.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                game.name,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: ThemeData.dark()
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topCenter,
                              child: Text(
                                '${genresAsString(game.genres)}',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: ThemeData.dark().textTheme.caption,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopTenBanner extends StatelessWidget {
  const TopTenBanner({
    Key key,
    @required this.topTenGamesList,
    @required this.orientation,
  }) : super(key: key);

  final List<Game> topTenGamesList;
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: PageView.builder(
        controller: PageController(
          initialPage: 0,
          viewportFraction: 0.9,
        ),
        itemBuilder: (BuildContext context, int index) {
          return TopTenItem(
            game: topTenGamesList[index],
          );
        },
        itemCount: topTenGamesList.length,
      ),
    );
  }
}

class TopTenItem extends StatelessWidget {
  const TopTenItem({
    Key key,
    @required this.game,
  }) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      tappable: false,
      openColor: Colors.transparent,
      openElevation: 0.0,
      openBuilder:
          (BuildContext context, void Function({Object returnValue}) action) {
        return const GameDetailsScreen();
      },
      closedColor: Colors.transparent,
      closedElevation: 0.0,
      closedBuilder: (BuildContext context, void Function() action) {
        return GestureDetector(
          onTap: () {
            Provider.gamesBlocOf(context).getGameDetails(game.id);
            action();
          },
          child: Card(
            margin: const EdgeInsets.only(
              top: 12.0,
              bottom: 12.0,
              right: 6.0,
              left: 6.0,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: Row(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: CachedNetworkImage(
                      imageUrl: game.backgroundImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Image.asset(
                          'assets/placeholder.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            game.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style:
                                ThemeData.dark().textTheme.bodyText1.copyWith(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            '${genresAsString(game.genres)}',
                            maxLines: 1,
                            style: ThemeData.dark().textTheme.caption,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoaderAnimated extends StatelessWidget {
  const LoaderAnimated({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.black54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: CircularProgressIndicator(),
            ),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key key,
    this.onTap,
    this.onSubmitted,
  }) : super(key: key);

  final VoidCallback onTap;
  final Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      margin: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 8.0, top: 12.0),
      color: ThemeData.dark().cardTheme.color,
      child: Container(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
        ),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Search Game',
            border: InputBorder.none,
          ),
          onSubmitted: onSubmitted,
          onTap: onTap,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }
}
