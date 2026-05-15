import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/spacing.dart';
import '../../core/widgets/primary_button.dart';

class FormPage extends StatelessWidget {
  const FormPage({
    required this.children,
    required this.submitLabel,
    super.key,
  });

  final List<Widget> children;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ...children.expand(
            (child) => [child, const SizedBox(height: AppSpacing.md)],
          ),
          const SizedBox(height: AppSpacing.xs),
          PrimaryButton(
            label: submitLabel,
            icon: Icons.check,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$submitLabel saved')));
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
