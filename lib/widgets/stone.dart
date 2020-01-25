import 'package:flutter/material.dart';
import 'package:goban/themes/gobanTheme.dart';

class Stone extends StatelessWidget {
  final StoneTheme theme;
  final double size;
  final bool last;
  final bool ghost;

  const Stone(
      {Key key, @required this.theme, @required this.size, this.last = false, this.ghost = false})
      : super(key: key);

  Color _getInverseColor(Color color) {
    var red = 255 - color.red;
    var blue = 255 - color.blue;
    var green = 255 - color.green;

    return Color.fromARGB(255, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    var indicatorSize = size - (size / 2.5);
    var indicatorMargin = (size - indicatorSize) / 2;
    var indicatorColor = _getInverseColor(theme.stoneColor);

    var stone = AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: size,
      height: size,
      decoration: BoxDecoration(
          border: Border.all(color: theme.borderColor, width: 2),
          color: !ghost ? theme.stoneColor : theme.stoneColor.withOpacity(.5),
          borderRadius: BorderRadius.circular(size)),
    );
    if (last) {
      return Stack(
        children: <Widget>[
          stone,
          Positioned(
            left: indicatorMargin,
            top: indicatorMargin,
            height: indicatorSize,
            width: indicatorSize,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: indicatorColor, width: 3),
                  color: theme.stoneColor,
                  borderRadius: BorderRadius.circular(indicatorSize)),
            ),
          )
        ],
      );
    } else {
      return stone;
    }
  }
}
