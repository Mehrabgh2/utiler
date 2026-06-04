import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class LoggerExamples extends StatelessWidget {
  const LoggerExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logger utilities', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () async {
                Logger.enabled = true;
                Logger.showWidget = true;
                Logger.export = false;

                await Logger.i('App started', tag: 'BOOT');
              },
              child: const Text('Logger: showWidget + log'),
            ),
            ElevatedButton(
              onPressed: () async {
                await PrettyLogger.s('Everything is fine', tag: 'OK');
              },
              child: const Text('PrettyLogger: success'),
            ),
            ElevatedButton(
              onPressed: () {
                StopwatchLogger(
                  'demo_timer',
                  Future.delayed(const Duration(milliseconds: 350)),
                );
              },
              child: const Text('StopwatchLogger'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'To view the in-app console, wrap your app with LoggerConsole.',
        ),
        const SizedBox(height: 8),
        const Text('Example: LoggerConsole(child: MyApp()).'),
      ],
    );
  }
}
