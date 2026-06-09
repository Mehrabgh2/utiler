import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

/// Demonstrates chainable [FormValidator] rules.
class ValidationExamples extends StatefulWidget {
  const ValidationExamples({super.key});

  @override
  State<ValidationExamples> createState() => _ValidationExamplesState();
}

class _ValidationExamplesState extends State<ValidationExamples> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _lastResult = 'Submit the form to validate';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Form validation', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator().required().email().build(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Iranian phone',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator().required().iranianPhone().build(),
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
                child: const Text('Validate form'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(_lastResult),
      ],
    );
  }
}
