String amsIdToLetter(int number) {
  try {
    const mapping = ["A", "B", "C", "D"];
    return mapping[number];
  } catch (e) {
    return "X";
  }
}