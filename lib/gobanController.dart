import 'dart:async';

import 'package:goban/data_classes/position.dart';
import 'package:goban/goban.dart';
import 'package:goban/models/game_logic.dart';
import 'package:goban/themes/gobanTheme.dart';

/// 
class BoardController {

  final int boardSize;
  final GobanTheme theme;
  GameState model;

  Stream<Move> get clicks => _clicks.stream;
  Stream<Move> get hovers => _hovers.stream.distinct(); // de-dupe

  final List<Move> history = [];

  final StreamController<Move> _clicks = StreamController<Move>();
  final StreamController<Move> _hovers = StreamController<Move>();

  BoardController({this.boardSize = 9, this.theme = GobanTheme.bookTheme})
  {
    model = GobanWithRules(boardSize);
  }

  // Call to clean up this controller.
  dispose() {
    _clicks.close();
    _hovers.close();
  }

  /// Notify the controller a position was hovered.
  void mouseHovered(Move position) => _hovers.add(position);

  /// Notify the controller a position was clicked.
  void clicked(Move position) => _clicks.add(position);
}
