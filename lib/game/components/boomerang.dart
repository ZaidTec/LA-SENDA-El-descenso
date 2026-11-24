class Boomerang {
  Boomerang({
    required this.row,
    required this.column,
    required this.rowDirection,
    required this.columnDirection,
  });

  double row;
  double column;
  final int rowDirection;
  final int columnDirection;

  void advance(double dt) {
    row += rowDirection * dt * 13;
    column += columnDirection * dt * 13;
  }
}
