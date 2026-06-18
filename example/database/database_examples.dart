import 'package:flutter/material.dart';
import 'package:utiler/src/database/database.dart';
import 'package:utiler/src/database/json_database_data.dart';
import 'package:utiler/src/database/secure_database_data.dart';

class DatabaseExamples extends StatefulWidget {
  const DatabaseExamples({super.key});

  @override
  State<DatabaseExamples> createState() => _DatabaseExamplesState();
}

class _DatabaseExamplesState extends State<DatabaseExamples> {
  String _status = 'Press buttons to test database';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Database utilities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () async {
                final db = Database();
                await db.init(logging: true);

                await db.putJson(
                  JsonDatabaseData(key: 'settings', data: {'theme': 'dark'}),
                );

                final settings = await db.getJson('settings');
                setState(() => _status = 'Json settings: ${settings?.data}');
              },
              child: const Text('Database: put/get JSON'),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = Database();
                await db.init(logging: true);

                await db.putSecure(
                  SecureDatabaseData(key: 'token', value: 'secret_token_123'),
                );

                final token = await db.getSecure('token');
                setState(() => _status = 'Secure token: ${token?.value}');
              },
              child: const Text('Database: put/get Secure'),
            ),
            ElevatedButton(
              onPressed: () async {
                final db = Database();
                await db.init(logging: false);
                await db.clearJson();
                await db.clearSecure();
                setState(() => _status = 'Cleared Json + Secure');
              },
              child: const Text('Database: clear both'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_status),
      ],
    );
  }
}
