import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/widgets/primary_button.dart';

/// Page de formulaire avec validation et bouton de soumission.
class FormPage extends StatelessWidget {
  const FormPage({
    required this.formKey,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    super.key,
  });

  /// Clé globale pour la validation du formulaire.
  final GlobalKey<FormState> formKey;
  /// Enfants (champs de formulaire).
  final List<Widget> children;
  /// Texte du bouton de soumission.
  final String submitLabel;
  /// Fonction appelée lors de la soumission.
  final Future<void> Function() onSubmit;

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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await onSubmit();
              }
            },
          ),
        ],
      ),
    );
  }
}
