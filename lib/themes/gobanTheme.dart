import 'package:flutter/material.dart';

class GobanTheme {
  static const defaultTheme = GobanTheme();

  static const bookTheme = GobanTheme(
      boardColor: Colors.white,
      lineColor: Colors.black,
      blackStones: StoneTheme(
          stoneColor: Colors.black,
          borderColor: Colors.black
      ),
      whiteStones: StoneTheme(
          stoneColor: Colors.white,
          borderColor: Colors.black
      )
  );

  static const jadeTheme = GobanTheme(
      boardColor: Colors.amberAccent,
      lineColor: Colors.black,
      blackStones: StoneTheme(
          stoneColor: Color(0xF08BC34A),
          borderColor: Color(0xF069F0AE)
      )
  );

  static const Color _defaultBoardColor = Colors.amber;
  static const Color _defaultLineColor = Colors.black;
  static const double _defaultLineWidth = 2.5;

  final Color boardColor, lineColor;
  final double lineWidth;
  final StoneTheme blackStones, whiteStones;

  const GobanTheme({
    this.boardColor = _defaultBoardColor,
    this.lineColor = _defaultLineColor,
    this.lineWidth = _defaultLineWidth,
    this.blackStones = StoneTheme.defaultBlackStones,
    this.whiteStones = StoneTheme.defaultWhiteStones,
  });
}

class StoneTheme {

  final Color stoneColor, borderColor;

  static const defaultBlackStones = StoneTheme(
      stoneColor: Colors.black,
      borderColor: Colors.black
  );

  static const defaultWhiteStones = StoneTheme(
      stoneColor: Colors.white,
      borderColor: Colors.white
  );

  const StoneTheme({
    @required this.stoneColor,
    @required this.borderColor
  });
}
