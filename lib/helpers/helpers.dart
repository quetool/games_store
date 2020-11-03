//
import 'package:rawg_sdk_dart/core/game.dart';

String genresAsString(List<Genres> genres) {
  return genres.map((g) => g.name).toList().join(' | ');
}
