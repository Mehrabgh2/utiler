import 'dart:async';

import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class CoreExamples extends StatefulWidget {
  const CoreExamples({super.key});

  @override
  State<CoreExamples> createState() => _CoreExamplesState();
}

class _CoreExamplesState extends State<CoreExamples> {
  late final StreamSubscription _sub;
  String _status = 'Tap button to check connectivity';

  @override
  void initState() {
    super.initState();
    _sub = InternetConnectivity.onStatusChange.listen((s) {
      if (mounted) {
        setState(() => _status = 'Network changed: $s');
      }
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
              child: const Text('Check current status'),
            ),
            ElevatedButton(
              onPressed: () {
                final either = Right<String, int>(42);
                final msg = either.fold((l) => 'Left: $l', (r) => 'Right: $r');
                debugPrint(msg);
              },
              child: const Text('Either.fold demo'),
            ),
            ElevatedButton(
              onPressed: () {
                final result = Guard<int>()(() => int.parse('123'));
                debugPrint('Guard success result: $result');
              },
              child: const Text('Guard sync demo'),
            ),
            ElevatedButton(
              onPressed: () async {
                final lazy = LazyValue<int>(() async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  return DateTime.now().millisecondsSinceEpoch;
                });

                final v1 = await lazy.value;
                final v2 = await lazy.value; // cached

                debugPrint('LazyValue: v1=$v1 v2=$v2 (same expected)');
              },
              child: const Text('LazyValue demo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_status),
      ],
    );
  }
}
