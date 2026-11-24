class Enemy {
  Enemy(this.row, this.column)
    : fromRow = row.toDouble(),
      fromColumn = column.toDouble();

  int row;
  int column;
  double fromRow;
  double fromColumn;
  double moveProgress = 1;
}
