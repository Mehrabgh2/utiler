import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utiler/src/service/api_service.dart';

class ServiceExamples extends StatefulWidget {
  const ServiceExamples({super.key});

  @override
  State<ServiceExamples> createState() => _ServiceExamplesState();
}

class _ServiceExamplesState extends State<ServiceExamples> {
  String _status = 'Press to call a demo endpoint';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service utilities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final api = ApiService(
              client: http.Client(),
              baseUrl: 'https://jsonplaceholder.typicode.com',
              logging: true,
            );

            try {
              final res = await api.get('/posts/1');
              setState(() => _status = 'GET /posts/1 -> ${res.statusCode}');
            } catch (e) {
              setState(() => _status = 'Request failed: $e');
            }
          },
          child: const Text('ApiService: GET example'),
        ),
        const SizedBox(height: 12),
        Text(_status),
      ],
    );
  }
}
