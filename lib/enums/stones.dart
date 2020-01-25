enum StoneColor { White, Black, Empty }

extension StoneColorExtensions on StoneColor {

  StoneColor flipped() => {
      StoneColor.White : StoneColor.Black,
      StoneColor.Black : StoneColor.White,
      StoneColor.Empty : StoneColor.Empty
    }[this];

}
