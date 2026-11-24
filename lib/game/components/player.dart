class Player {
  Player({required this.row, required this.column})
    : fromRow = row.toDouble(),
      fromColumn = column.toDouble();

  int row;
  int column;
  double fromRow;
  double fromColumn;
  double moveProgress = 1;
  int facingRow = 0;
  int facingColumn = 1;

  double get visualRow =>
      fromRow + (row - fromRow) * _ease(moveProgress);

  double get visualColumn =>
      fromColumn + (column - fromColumn) * _ease(moveProgress);

  void face(int rowDelta, int columnDelta) {
    if (rowDelta == 0 && columnDelta == 0) {
      return;
    }
    facingRow = rowDelta;
    facingColumn = columnDelta;
  }

  void moveTo(int nextRow, int nextColumn) {
    fromRow = visualRow;
    fromColumn = visualColumn;
    moveProgress = 0;
    row = nextRow;
    column = nextColumn;
  }

  void update(double dt) {
    moveProgress = (moveProgress + dt / .11).clamp(0.0, 1.0);
  }

  double _ease(double progress) {
    final value = progress.clamp(0.0, 1.0);
    return value * value * (3 - 2 * value);
  }
}
