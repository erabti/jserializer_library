extension CircularTakeExtension<T> on Iterable<T> {
  Iterable<T> takeCircular(int count, {int startIndex = 0}) sync* {
    if (isEmpty) return;

    final list = toList(); // Convert to list for easier index access
    final length = list.length;

    // Normalize the start index to ensure it's always within bounds
    startIndex = startIndex % length;
    if (startIndex < 0) startIndex = (length + startIndex) % length;

    int yielded = 0;
    int currentIndex = startIndex;

    while (yielded < count) {
      yield list[currentIndex];
      yielded++;
      currentIndex = (currentIndex + 1) % length;
    }
  }
}

extension CircularIndexExtension<T> on List<T> {
  T? circularAt(int index) {
    if (isEmpty) return null;

    // Handle negative indices by converting them to positive
    if (index < 0) {
      index = length - (-index % length);
    }

    // Use modulo to wrap around the list
    return this[index % length];
  }
}
