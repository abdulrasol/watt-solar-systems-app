class BomItem {
  const BomItem({
    required this.name,
    required this.unit,
    required this.quantity,
    this.note,
  });

  final String name;
  final String unit;
  final double quantity;
  final String? note;
}
