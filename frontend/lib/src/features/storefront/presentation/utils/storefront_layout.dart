int storefrontProductColumns(double width) {
  if (width >= 1100) return 4;
  if (width >= 700) return 3;
  return 1;
}

int storefrontSquareGridColumns(double width) {
  if (width >= 1100) return 4;
  if (width >= 700) return 3;
  return 2;
}

int storefrontTwoRowProductCount(double width) {
  return storefrontProductColumns(width) * 2;
}

int storefrontTwoRowSquareCount(double width) {
  return storefrontSquareGridColumns(width) * 2;
}
