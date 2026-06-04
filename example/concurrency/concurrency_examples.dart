import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class ConcurrencyExamples extends StatelessWidget {
  const ConcurrencyExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Concurrency utilities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () async {
                const executor = BactchExecutor();
                final results = await executor.execute([
                  () async => 'A',
                  () async => 'B',
                  () async {
                    throw Exception('Simulated failure');
                  },
                ]);

                debugPrint('Batch results: $results');
              },
              child: const Text('BatchExecutor: run sequential'),
            ),
            ElevatedButton(
              onPressed: () async {
                final executor = ParallelExecutor(indexImportant: true);
                final results = await executor.execute<String>([
                  () async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    return 'User';
                  },
                  () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    return 'Posts';
                  },
                  () async {
                    await Future.delayed(const Duration(milliseconds: 200));
                    return 'Comments';
                  },
                ]);

                debugPrint('Parallel results: $results');
              },
              child: const Text('ParallelExecutor: run in parallel'),
            ),
          ],
        ),
      ],
    );
  }
}
