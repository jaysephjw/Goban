import 'package:flutter/material.dart';
import 'package:goban/data_classes/position.dart';
import 'package:goban/enums/stones.dart';
import 'package:goban/gobanController.dart';
import 'package:goban/models/game_logic.dart';
import 'package:goban/themes/gobanTheme.dart';
import 'package:goban/helpers/starPoints.dart';

import 'dart:ui' as ui;

class GobanWidget extends StatelessWidget {

  final BoardController controller;

  const GobanWidget({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          print('Constraints $constraints');

          final width = constraints.widthConstraints().smallest.width;
          final borderCellSize = controller.theme.borderSizeInCells;
          final cellSize = width / (controller.boardSize + borderCellSize + borderCellSize);
          final borderSize = cellSize * borderCellSize;
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                controller.theme.boardShadow,
              ]
            ),
            child: CustomPaint(
              painter: _BackgroundPainter(controller.theme),
              child: Padding(
                padding: EdgeInsets.all(borderSize),
                child: _InnerBoardWidget(controller: controller),
              ),
            ),
          );
        }
      ),
    );
  }
}


/// A widget that draws a go board :) Does not include any of the padding around the board.
///
/// Uses all available width; provide at least that much height.
class _InnerBoardWidget extends StatefulWidget {

  final BoardController controller;


  _InnerBoardWidget({key, @required this.controller}) : super(key: key);

  @override
  _InnerBoardWidgetState createState() => _InnerBoardWidgetState();
}

class _InnerBoardWidgetState extends State<_InnerBoardWidget> {

  Move _ghost;

  @override
  Widget build(BuildContext context) {
    print('built');
    return Listener(
      onPointerHover: (event) {
        setState(() {
          print('on hover');
          final localPosition = _localPosition(event.position);
          final nearest = moveForOffset(widget.controller, context.size, localPosition);
          widget.controller.mouseHovered(nearest);
          _ghost = nearest;
        });
      },
      onPointerExit: (event) {
        setState(() {
          widget.controller.mouseHovered(null);
          _ghost = null;
        });
      },
      child: GestureDetector(
        child: CustomPaint(painter: _BoardPainter(widget.controller.model, widget.controller.theme, _ghost)),
        onTapUp: (event) {
          final localPosition = _localPosition(event.globalPosition);
          final nearest = moveForOffset(widget.controller, context.size, localPosition);
          widget.controller.clicked(nearest);
          print('on onTapUp $nearest');
        },
      ),
    );
  }

  Offset _localPosition(Offset globalPosition) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }
}

/// Paints the background of the board.
class _BackgroundPainter extends CustomPainter {

  final GobanTheme theme;
  final Paint boardPaint;
//  static Paint boardPaint = Paint()..color = Color(0xFFDDB06C);

  _BackgroundPainter(this.theme) :
        boardPaint = Paint()..color = theme.boardColor
  ;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, size.height, size.width, 0);

    if (theme.boardGradient != null) {
      Paint p = Paint()..shader = theme.boardGradient.createShader(rect);
      canvas.drawRect(rect, p);
    } else {
      canvas.drawRect(rect, boardPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Paints the lines and stones of the board.  Does not paint the background.
class _BoardPainter extends CustomPainter {

  final GameState model;
  final GobanTheme theme;
  final Move ghost;

  static Paint hoverPaint = Paint()..color = (Colors.grey[600].withOpacity(.5));

  final Paint linePaint, blackStoneFill, blackStoneBorder, whiteStoneFill, whiteStoneBorder;

  _BoardPainter(this.model, this.theme, this.ghost) :
        linePaint = Paint()..color = theme.lineColor..strokeWidth = theme.lineWidth,
        blackStoneFill = Paint()..color = theme.blackStones.stoneColor,
        blackStoneBorder = Paint()
          ..color = theme.blackStones.borderColor ?? Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
        whiteStoneFill = Paint()..color = theme.whiteStones.stoneColor,
        whiteStoneBorder = Paint()
          ..color = theme.whiteStones.borderColor ?? Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
  ;

  @override
  void paint(Canvas canvas, Size size) {

    assert(size.height >= size.width, '_BoardPainter needs at least its width in height.');

    final lines = model.size;
    final cellSize = size.width / (lines - 1); // Length between each line
    final stoneSize = cellSize / 2;
    final starPointSize = cellSize / 10;

    // Draw the grid lines
    List.generate(lines, (i) => i).forEach((i) { // For each line...
      final offset = i * cellSize;
      final edge = cellSize * (model.size - 1);
      canvas.drawLine(
          size.topLeft(Offset(offset, 0)),
          size.topLeft(Offset(offset, edge)),
          linePaint); // Draw column
      canvas.drawLine(
          size.topLeft(Offset(0, offset)),
          size.topLeft(Offset(edge, offset)),
          linePaint); // Draw row
    });

    // Draw the dots and stones :)
    model.positions().forEach((p) {
      final Offset offset = Offset(p.x * cellSize, p.y * cellSize);
      if (p.isEmpty) {
        if (StarPoints.isStarPoint(p, model.size)) {
          canvas.drawCircle(offset, starPointSize, linePaint);
        } else {
//          canvas.drawCircle(offset, 0, linePaint);
        }
      } else {
        drawStone(p, offset, cellSize, canvas);
//        canvas.drawCircle(offset, stoneSize, _paintForStone(p.color));
      }
    });

    // Draw the hover cursor
    if (ghost != null) {
      final Offset offset = Offset(ghost.x * cellSize, ghost.y * cellSize);
      canvas.drawCircle(offset, stoneSize, hoverPaint);
    }
  }

  void drawStone(Move p, Offset center, double cellSize, Canvas canvas) {
    final radius = (cellSize / 2) - 1;

    // Draw the stone
    Paint stonePaint = p.isBlack ? blackStoneFill : whiteStoneFill;
    canvas.drawCircle(center, radius, stonePaint);

    // Draw glint, if any
    final focus = cellSize / 6;
    if (p.isBlack && theme.blackStones.glint)  {
      final gradient =
      ui.Gradient.radial(center.translate(-focus, -focus), radius,
          [
            Colors.white.withOpacity(.4),
            Colors.white.withOpacity(0),
          ]);
      final gradientPaint = new Paint()..shader = gradient;
      canvas.drawCircle(center, cellSize / 2, gradientPaint);
    } else if (p.isWhite && theme.whiteStones.glint) {
      final gradient =
      ui.Gradient.radial(center.translate(focus * 1.1, focus * 1.1), radius,
          [
            Colors.white.withOpacity(.5),
            Colors.white.withOpacity(1),
          ]);
      final gradientPaint = new Paint()..shader = gradient;
      canvas.drawCircle(center, cellSize / 2, gradientPaint);
    }

    // Draw border, ( may be transparent ;) this is hacky. )
    final borderPaint = p.isBlack ? blackStoneBorder : whiteStoneBorder;
    canvas.drawCircle(center, radius - (borderPaint.strokeWidth / 2), borderPaint);
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

//  @override
//  bool shouldRepaint(CustomPainter oldDelegate) {
//    return (oldDelegate as _BoardPainter).board != board;
//  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;


  Paint _paintForStone(StoneColor color) {
    return color == StoneColor.White ? whiteStoneFill : blackStoneFill;
  }

}

Move moveForOffset(BoardController board, Size boardSize, Offset localPosition) {
  final double cellSize = boardSize.width / (board.model.size - 1);
  final int x = (localPosition.dx / cellSize).round();
  final int y = (localPosition.dy / cellSize).round();
  final Move nearest = board.model.positionAt(x, y);
  return nearest;
}

