import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class CoreExamples extends StatefulWidget {
  const CoreExamples({super.key});

  @override
  State<CoreExamples> createState() => _CoreExamplesState();
}

class _CoreExamplesState extends State<CoreExamples> {
  late final StreamSubscription<InternetStatus> _sub;
  String _status = 'Tap a button to run a demo';

  final TimedCache<String, String> _cache = TimedCache(
    ttl: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    _sub = InternetConnectivity.onStatusChange.listen((s) {
      if (mounted) setState(() => _status = 'Network changed: $s');
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Core utilities', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () async {
                final s = await InternetConnectivity.currentStatus;
                setState(() => _status = 'Current status: $s');
              },
              child: const Text('Check connectivity'),
            ),
            ElevatedButton(
              onPressed: () {
                final either = Right<String, int>(42);
                final mapped = either.map((n) => n * 2);
                final msg = mapped.fold((l) => 'Left: $l', (r) => 'Right: $r');
                setState(() => _status = 'Either.map: $msg');
              },
              child: const Text('Either.map demo'),
            ),
            ElevatedButton(
              onPressed: () {
                final either = Right<String, int>(42);
                final chained = either.flatMap(
                  (n) => n > 0 ? Right(n * 10) : Left('negative'),
                );
                setState(
                  () => _status = 'Either.flatMap: ${chained.getOrElse(0)}',
                );
              },
              child: const Text('Either.flatMap demo'),
            ),
            ElevatedButton(
              onPressed: () {
                final result = Guard<int>()(() => int.parse('123'));
                setState(() => _status = 'Guard result: $result');
              },
              child: const Text('Guard sync demo'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await AsyncGuard<String>()(() async {
                  await Future.delayed(const Duration(milliseconds: 100));
                  return 'async result';
                });
                setState(() => _status = 'AsyncGuard result: $result');
              },
              child: const Text('AsyncGuard demo'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await AsyncGuard<String>()(() async {
                  throw Exception('intentional error');
                });
                setState(
                  () =>
                      _status = 'AsyncGuard on error: $result (null expected)',
                );
              },
              child: const Text('AsyncGuard error demo'),
            ),
            ElevatedButton(
              onPressed: () {
                _cache.set('greeting', 'hello');
                final hit = _cache.get('greeting');
                setState(() => _status = 'TimedCache hit: $hit (TTL 10s)');
              },
              child: const Text('TimedCache set/get'),
            ),
            ElevatedButton(
              onPressed: () async {
                final lazy = LazyValue<int>(() async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  return DateTime.now().millisecondsSinceEpoch;
                });

                final v1 = await lazy.value;
                final v2 = await lazy.value;
                setState(() => _status = 'LazyValue same: ${v1 == v2} ($v1)');
              },
              child: const Text('LazyValue demo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'ConnectivityWidget — rebuilds automatically on status change:',
        ),
        const SizedBox(height: 8),
        ConnectivityWidget(
          connected: (ctx) => const Text('Online'),
          disconnected: (ctx) => const Text('Offline'),
          vpn: (ctx) => const Text('VPN'),
        ),
        const SizedBox(height: 12),
        Text(_status),
      ],
    );
  }
}
