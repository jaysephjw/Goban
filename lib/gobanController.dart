import 'dart:async';

import 'package:goban/data_classes/position.dart';
import 'package:goban/goban.dart';
import 'package:goban/models/game_logic.dart';
import 'package:goban/themes/gobanTheme.dart';

class GobanController {
  final int boardSize;
  final GobanTheme theme;

  GobanModel model;

  Stream<Move> get clicks => _clicks.stream;
  Stream<Move> get hovers => _hovers.stream.distinct(); // de-dupe

  final StreamController<Move> _clicks = StreamController<Move>();
  final StreamController<Move> _hovers = StreamController<Move>();

  GobanController({this.boardSize = 9, this.theme = GobanTheme.bookTheme})
  {
    model = GobanWithRules(boardSize);
  }

  // Call to clean up this controller.
  dispose() {
    _clicks.close();
    _hovers.close();
  }

  void mouseHovered(Move position) => _hovers.add(position);

  void clicked(Move position) => _clicks.add(position);
}
