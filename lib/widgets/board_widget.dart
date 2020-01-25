import 'package:flutter/material.dart';
import 'package:goban/data_classes/position.dart';
import 'package:goban/enums/stones.dart';
import 'package:goban/gobanController.dart';
import 'package:goban/models/game_logic.dart';
import 'package:goban/themes/gobanTheme.dart';
import 'package:goban/helpers/starPoints.dart';

import 'dart:ui' as ui;

class BoardWidget extends StatelessWidget {

  final GobanController controller;

  const BoardWidget({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final double inset = 20; // TODO: Calculate more elegantly (e.g. 1 cell-size)

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        elevation: 10,
        child: CustomPaint(
          painter: _BackgroundPainter(),
          child: Padding(
            padding: EdgeInsets.all(inset),
            child: _InnerBoardWidget(controller: controller),
          ),
        ),
      ),
    );
  }
}


/// A widget that draws a go board :) Does not include any of the padding around the board.
///
/// Uses all available width; provide at least that much height.
class _InnerBoardWidget extends StatefulWidget {

  final GobanController controller;


  _InnerBoardWidget({key, @required this.controller}) : super(key: key);

  @override
  _InnerBoardWidgetState createState() => _InnerBoardWidgetState();
}

class _InnerBoardWidgetState extends State<_InnerBoardWidget> {

  // State
  BuildContext _context;
  Offset _hover;

  @override
  Widget build(BuildContext context) {
    this._context = context;

    return Listener(
      onPointerHover: (event) {
        setState(() {
          final localPosition = _localPosition(event.position);
          final nearest = moveForOffset(widget.controller, _context.size, localPosition);
          widget.controller.mouseHovered(nearest);
        });
      },
      onPointerExit: (event) {
        setState(() {
          widget.controller.mouseHovered(null);
        });
      },
      child: GestureDetector(
        child: CustomPaint(painter: _BoardPainter(widget.controller.model, widget.controller.theme)),
        onTapUp: (event) {
          final localPosition = _localPosition(event.globalPosition);
          final nearest = moveForOffset(widget.controller, _context.size, localPosition);
          widget.controller.clicked(nearest);
        },
      ),
    );
  }

  Offset _localPosition(Offset globalPosition) {
    final RenderBox renderBox = _context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }
}

/// Paints the background of the board.
class _BackgroundPainter extends CustomPainter {

  static Paint boardPaint = Paint()..color = Color(0xFFDDB06C);

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Rect.fromPoints(
          size.topLeft(Offset.zero),
          size.bottomRight(Offset.zero)),
          boardPaint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Paints the lines and stones of the board.  Does not paint the background.
class _BoardPainter extends CustomPainter {

  final GobanModel model;
  final GobanTheme theme;

  static Paint linePaint = Paint()..color = Colors.black..strokeWidth = 1.1;
  static Paint blackStonePaint = Paint()..color = Colors.grey[900];
  static Paint whiteStonePaint = Paint()..color = Colors.grey[350];
  static Paint hoverPaint = Paint()..color = (Colors.grey[600].withOpacity(.5));

  final Paint blackStoneFill, blackStoneBorder, whiteStoneFill, whiteStoneBorder;

  _BoardPainter(this.model, this.theme) :
        blackStoneFill = Paint()..color = theme.blackStones.stoneColor,
        blackStoneBorder = Paint()..color = theme.blackStones.borderColor,
        whiteStoneFill = Paint()..color = theme.whiteStones.stoneColor,
        whiteStoneBorder = Paint()..color = theme.whiteStones.borderColor
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
    if (model.ghost != null) {
      final Offset offset = Offset(model.ghost.x * cellSize, model.ghost.y * cellSize);
      canvas.drawCircle(offset, stoneSize, hoverPaint);
    }
  }

  void drawStone(Move p, Offset center, double cellSize, Canvas canvas) {

    final size = Size(cellSize / 2, cellSize / 2);

    canvas.drawCircle(center, cellSize / 2, _paintForStone(p.color));

    final focus = cellSize / 6;
    final radius = cellSize / 2;

    final gradient = p.isBlack ?
    ui.Gradient.radial(center.translate(-focus, -focus), radius,
        [
          Colors.white.withOpacity(.5),
          Colors.white.withOpacity(0),
        ]) :
    ui.Gradient.radial(center.translate(focus, focus), radius,
        [
          Colors.white.withOpacity(.0),
          Colors.white.withOpacity(.4),
        ]);
    final gradientPaint = new Paint()..shader = gradient;

    canvas.drawCircle(center, cellSize / 2, gradientPaint);

//    canvas.drawPath(
//        Path()
//          ..addOval(
//              Rect.fromPoints(center, center.translate(size.width, size.height)))
////          ..fillType = PathFillType.evenOddx
//        ,
//        Paint()
//      ..color= Colors.black.withOpacity(.5)
//      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(3)));



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
    return color == StoneColor.White ? whiteStonePaint : blackStonePaint;
  }

}

Move moveForOffset(GobanController board, Size boardSize, Offset localPosition) {
  final double cellSize = boardSize.width / (board.model.size - 1);
  final int x = (localPosition.dx / cellSize).round();
  final int y = (localPosition.dy / cellSize).round();
  final Move nearest = board.model.positionAt(x, y);
  return nearest;
}

