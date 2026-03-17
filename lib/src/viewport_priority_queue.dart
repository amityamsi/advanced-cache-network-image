import 'dart:collection';

class ViewportPriorityQueue {
  static final Queue<Function> _queue = Queue();

  static int _running = 0;
  static const int maxConcurrent = 3;

  static void add(Function task) {
    _queue.add(task);
    _run();
  }

  static void _run() {
    if (_running >= maxConcurrent) return;

    if (_queue.isEmpty) return;

    final task = _queue.removeFirst();

    _running++;

    Future(() async {
      await task();
      _running--;
      _run();
    });
  }
}
