import 'package:flutter/material.dart';

import '../../app/theme/spacing.dart';
import '../../core/widgets/primary_button.dart';

class FormPage extends StatelessWidget {
  const FormPage({
    required this.formKey,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
              if (formKey.currentState!.validate()) {
                onSubmit();
              }
            },
          ),
        ],
      ),
    );
  }
}
