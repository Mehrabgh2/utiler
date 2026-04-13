class Retry {
  Future<T?> call<T>(
    Future<T?> Function() task, {
    int maxAttempts = 3,
    int delayMilliseconds = 300,
  }) async {
    int attempts = 0;

    while (true) {
      try {
        return await task();
      } catch (e) {
        attempts++;
        if (attempts > maxAttempts) {
          return null;
        }
        await Future.delayed(Duration(milliseconds: delayMilliseconds));
      }
    }
  }
}
