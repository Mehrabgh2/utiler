import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

/// Single-file example that demonstrates all classes from `lib/src/async/`:
/// - Debouncer
/// - Throttler
/// - Retry
class AsyncExamples extends StatefulWidget {
  const AsyncExamples({super.key});

  @override
  State<AsyncExamples> createState() => _AsyncExamplesState();
}

class _AsyncExamplesState extends State<AsyncExamples> {
  late final Debouncer _debouncer;
  late final Throttler _throttler;

  final _controller = TextEditingController();

  String _retryStatus = 'Press "Run retry"';

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(400);
    _throttler = Throttler(1000);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDebouncedChanged(String value) {
    _debouncer(() {
      debugPrint('Debounced: $value');
    });
  }

  void _onThrottledTap() {
    _throttler(() {
      debugPrint('Throttled tap executed');
    });
  }

  Future<String> _unstableTask() async {
    await Future.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now().microsecondsSinceEpoch;
    if (now % 2 == 0) {
      throw Exception('Intermittent failure');
    }

    return 'Succeeded at ${DateTime.now()}';
  }

  Future<void> _runRetry() async {
    setState(() => _retryStatus = 'Running with retries...');

    final retry = Retry();
    final result = await retry.call<String>(
      _unstableTask,
      maxAttempts: 5,
      delayMilliseconds: 400,
    );

    setState(() {
      _retryStatus = result == null
          ? 'Failed after retries'
          : 'Success: $result';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Async Utilities (Debouncer / Throttler / Retry)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _controller,
          onChanged: _onDebouncedChanged,
          decoration: const InputDecoration(
            labelText: 'Debouncer: type to trigger delayed action',
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: _onThrottledTap,
              child: const Text('Throttler: tap quickly'),
            ),
            ElevatedButton(
              onPressed: _runRetry,
              child: const Text('Run retry task'),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Text(_retryStatus),
      ],
    );
  }
}
