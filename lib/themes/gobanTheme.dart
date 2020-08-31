import 'package:flutter/material.dart';

class GobanTheme {

  static const defaultTheme = GobanTheme();

  static const bookTheme = GobanTheme(
      boardColor: Colors.white,
      lineColor: Colors.black,
      blackStones: StoneTheme(
          stoneColor: Colors.black,
          glint: false,
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
      ),
      whiteStones: StoneTheme(
          stoneColor: Color(0xF0FFB300),
          borderColor: Color(0xF0FFA000)
      ),
  );

  static const Color _defaultBoardColor = Colors.amber;
  static const LinearGradient _defaultBoardGradient = null;
  static const BoxShadow _defaultBoardShadow = const BoxShadow(
    color: Colors.black38,
    blurRadius: 4,
    offset: Offset(0, 6),
  );
  static const Color _defaultLineColor = Colors.black;
  static const double _defaultLineWidth = 2.5;
  static const double _defaultBorderSizeInCells = .8;

  final Color boardColor;
  final LinearGradient boardGradient;
  final BoxShadow boardShadow;
  final double borderSizeInCells;
  final Color lineColor;
  final double lineWidth;
  final StoneTheme blackStones, whiteStones;

  const GobanTheme({
    this.boardColor = _defaultBoardColor,
    this.boardGradient = _defaultBoardGradient,
    this.boardShadow = _defaultBoardShadow,
    this.lineColor = _defaultLineColor,
    this.lineWidth = _defaultLineWidth,
    this.borderSizeInCells = _defaultBorderSizeInCells,
    this.blackStones = StoneTheme.defaultBlackStones,
    this.whiteStones = StoneTheme.defaultWhiteStones,
  });
}

class StoneTheme {

  final bool glint;
  final Color stoneColor;
  final Color borderColor;

  static const defaultBlackStones = StoneTheme(
      stoneColor: Colors.black,
      glint: true
  );

  static const defaultWhiteStones = StoneTheme(
      stoneColor: Color(0xFFCCCCCC),
      glint: true
  );

  const StoneTheme({
    @required this.stoneColor,
    this.borderColor,
    this.glint = false,
  });
}
