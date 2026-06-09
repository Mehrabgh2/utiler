import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

/// Demonstrates [AppConfig], [AppConfigStore], and [FeatureFlags].
class ConfigExamples extends StatefulWidget {
  const ConfigExamples({super.key});

  @override
  State<ConfigExamples> createState() => _ConfigExamplesState();
}

class _ConfigExamplesState extends State<ConfigExamples> {
  String _status = 'Tap a button to run a demo';

  late final AppConfigStore _configStore = AppConfigStore(
    active: AppEnvironment.development,
    configs: {
      AppEnvironment.development: AppConfig.fromMap(
        environment: AppEnvironment.development,
        data: {'api_base_url': 'http://localhost:8080'},
      ),
      AppEnvironment.production: AppConfig.fromMap(
        environment: AppEnvironment.production,
        data: {'api_base_url': 'https://api.example.com'},
      ),
    },
  );

  late final FeatureFlags _flags = FeatureFlags({
    'new_checkout': true,
    'beta_chat': false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App config & feature flags',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () {
                final url = _configStore.active.require<String>('api_base_url');
                setState(() => _status = 'Active API URL: $url');
              },
              child: const Text('AppConfigStore'),
            ),
            ElevatedButton(
              onPressed: () {
                final checkout = _flags.isEnabled('new_checkout');
                final chat = _flags.isEnabled('beta_chat');
                setState(
                  () => _status = 'new_checkout=$checkout, beta_chat=$chat',
                );
              },
              child: const Text('FeatureFlags'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_status),
      ],
    );
  }
}
