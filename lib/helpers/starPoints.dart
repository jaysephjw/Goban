import 'package:goban/data_classes/position.dart';

class StarPoints {

  static bool isStarPoint(Move move, boardSize) =>
      stars(boardSize).any((m) => m.locationEquals(move));

  static List<Move> stars(int size) => _starsMap[size] ?? [];

  static const Map<int, List<Move>> _starsMap = {
    9: starPoints9x9,
    13: starPoints13x13,
    19: starPoints19x19,
  };

  static const starPoints9x9 = const [
    Move.empty(2, 2), Move.empty(2, 6),
    Move.empty(4, 4),
    Move.empty(6, 2), Move.empty(6, 6)
  ];
  static const  starPoints13x13 = const [
    Move.empty(3, 3), Move.empty(3, 9),
    Move.empty(6, 6),
    Move.empty(9, 3), Move.empty(9, 9)
  ];
  static const  starPoints19x19 = const [
    Move.empty(3, 3), Move.empty(3, 15), Move.empty(3, 9),
    Move.empty(9, 3), Move.empty(9, 9), Move.empty(9, 15),
    Move.empty(15, 3), Move.empty(15, 9), Move.empty(15, 15),
  ];
}
