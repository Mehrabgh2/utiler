import 'package:flutter/material.dart';
import 'package:utiler/utiler.dart';

class UiExamples extends StatefulWidget {
  const UiExamples({super.key});

  @override
  State<UiExamples> createState() => _UiExamplesState();
}

class _UiExamplesState extends State<UiExamples> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      color: Colors.white,
      maintainBottomViewPadding: true,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'UI utilities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              12.v,
              KeyboardDismiss(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'KeyboardDismiss text field',
                  ),
                ),
              ),
              12.v,
              InkwellButton(
                borderRadius: 12,
                color: Colors.blueGrey.shade50,
                overlayColor: Colors.blue.withValues(alpha: 0.15),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('InkwellButton (tap me)'),
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
              12.v,
              ExpandableWidget(
                expand: _expanded,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: const Text('Expanded content'),
                ),
              ),
              16.v,
              Text(
                'Responsive scale example: ${Responsive.of(context).scale(100).toStringAsFixed(1)}',
              ),
              12.v,
              Text('Hex color: ${"FF5733".toColor}'),
              12.v,
              Text('Gap widget example: ${Gaps.v16.height} px vertical gap'),
            ],
          ),
        ),
      ),
    );
  }
}
