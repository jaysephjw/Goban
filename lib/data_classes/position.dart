import 'dart:ui';

import 'package:goban/enums/stones.dart';

class Move {
  final int x;
  final int y;
  final StoneColor color;

  const Move(this.x, this.y, this.color)
      : assert (color != null),
        assert(y != null),
        assert(x != null);

  const Move.empty(int x, int y) : this(x, y, StoneColor.Empty);

  bool get isBlack => this.color == StoneColor.Black;
  bool get isWhite => this.color == StoneColor.White;
  bool get isEmpty => this.color == StoneColor.Empty;

  Move cleared() => Move(x, y, StoneColor.Empty);

  Move copy({x, y, color}) {
    return Move(x ?? this.x, y ?? this.y, color ?? this.color);
  }

  @override
  bool operator ==(other) {
    return other is Move && other.x == x && other.y == y;
  }

  @override
  int get hashCode => hashValues(x, y, color);

  @override
  String toString() =>
      isEmpty ? '($x, $y)' : '($x, $y, ${isBlack ? 'B' : 'W'})';

  bool locationEquals(Move other) => x == other.x && y == other.y;
}

extension PositionExtensions on Move {
}
