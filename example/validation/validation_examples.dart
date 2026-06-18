import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

/// Demonstrates [FormValidator] and [AsyncFormValidator].
class ValidationExamples extends StatefulWidget {
  const ValidationExamples({super.key});

  @override
  State<ValidationExamples> createState() => _ValidationExamplesState();
}

class _ValidationExamplesState extends State<ValidationExamples> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _optionalController = TextEditingController();
  final _asyncEmailController = TextEditingController();

  String _lastResult = 'Submit the form to validate';
  String _asyncResult = 'Tap async validate to check';
  bool _asyncLoading = false;

  final _asyncValidator = AsyncFormValidator().required().email().rule((
    value,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate server check — "taken@example.com" is already taken
    return value == 'taken@example.com' ? 'Email already in use' : null;
  });

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _optionalController.dispose();
    _asyncEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Form validation', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Sync FormValidator
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (required)',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator().required().email().build(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Iranian phone (required)',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator().required().iranianPhone().build(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optionalController,
                decoration: const InputDecoration(
                  labelText:
                      'Website URL (optional — validated only if filled)',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator().optional().url().build(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _lastResult = 'All fields valid ✓');
                  } else {
                    setState(() => _lastResult = 'Validation failed');
                  }
                },
                child: const Text('Validate'),
              ),
              const SizedBox(height: 8),
              Text(_lastResult),
            ],
          ),
        ),

        const Divider(height: 32),
        Text(
          'Async validation (server-side rule)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _asyncEmailController,
          decoration: const InputDecoration(
            labelText: 'Email (try taken@example.com)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _asyncLoading
              ? null
              : () async {
                  setState(() => _asyncLoading = true);
                  final error = await _asyncValidator.validate(
                    _asyncEmailController.text,
                  );
                  setState(() {
                    _asyncLoading = false;
                    _asyncResult = error ?? 'Valid ✓';
                  });
                },
          child: _asyncLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Async validate'),
        ),
        const SizedBox(height: 8),
        Text(_asyncResult),
      ],
    );
  }
}
