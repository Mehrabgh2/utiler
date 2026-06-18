import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class ExtensionExamples extends StatelessWidget {
  const ExtensionExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extension utilities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text('String:'.toTitleCase),
        const SizedBox(height: 8),
        Text('"hello world" -> snake_case: ${"hello world".toSnakeCase}'),
        const SizedBox(height: 8),
        Text('"123" -> toIntOrNull: ${"123".toIntOrNull}'),
        const SizedBox(height: 8),
        Text('123 -> Persian: ${123.toPersianNumber}'),
        const SizedBox(height: 8),
        Text('Color hex: "FF5733" -> ${"FF5733".toColor}'),
        const SizedBox(height: 8),
        Text('List unique: ${[1, 1, 2, 3].unique}'),
        const SizedBox(height: 8),
        Text('Map merge: ${{'"a"': 1}.merge({'"b"': 2})}'),
        const SizedBox(height: 8),
        Text('Gap usage example: 16.h and 8.v'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: Row(
            children: [const Text('Hello'), 16.h, const Text('World')],
          ),
        ),
        const SizedBox(height: 12),
        Text('DateTime:'.toTitleCase),
        const SizedBox(height: 8),
        Text('isToday: ${DateTime.now().isToday}'),
        const SizedBox(height: 8),
        Text(
          'isPast: ${DateTime.now().subtract(const Duration(days: 1)).isPast}',
        ),
        const SizedBox(height: 8),
        Text(
          'timeAgo: ${DateTime.now().subtract(const Duration(hours: 3)).timeAgo}',
        ),
        const SizedBox(height: 8),
        Text('format: ${DateTime.now().format('yyyy/MM/dd')}'),
        const SizedBox(height: 8),
        Text('isSameDay: ${DateTime.now().isSameDay(DateTime.now())}'),
      ],
    );
  }
}
