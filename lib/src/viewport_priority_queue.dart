import 'dart:collection';

/// A queue system that controls the number of concurrent tasks,
/// prioritizing smooth performance in image-heavy UIs.
///
/// This is mainly used for:
/// - Limiting simultaneous image downloads
/// - Preventing network congestion
/// - Improving scrolling performance
///
/// It ensures that only a fixed number of tasks run at the same time,
/// while remaining tasks are queued and executed sequentially.
class ViewportPriorityQueue {
  /// Internal queue holding pending tasks.
  static final Queue<Function> _queue = Queue();

  /// Number of currently running tasks.
  static int _running = 0;

  /// Maximum number of concurrent tasks allowed.
  ///
  /// Defaults to `3`.
  static const int maxConcurrent = 3;

  /// Adds a new [task] to the queue.
  ///
  /// The task will be executed when a slot becomes available.
  ///
  /// Example:
  /// ```dart
  /// ViewportPriorityQueue.add(() async {
  ///   await fetchImage();
  /// });
  /// ```
  static void add(Function task) {
    _queue.add(task);
    _run();
  }

  /// Executes tasks from the queue while respecting
  /// the [maxConcurrent] limit.
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
