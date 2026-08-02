import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/premium_components.dart';
import 'profile_editable_row.dart';
import '../providers/profile_provider.dart';

/// Carte des informations personnelles éditables du profil.
class ProfileInfoCard extends ConsumerWidget {
  const ProfileInfoCard({super.key, required this.profile});

  /// Profil utilisateur observé.
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileProvider.notifier);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      elevated: true,
      child: Column(
        children: [
          ProfileEditableRow(
            label: 'Name',
            value: profile.displayName.isNotEmpty ? profile.displayName : '—',
            icon: Icons.person_outline,
            onTap: () => _showEditDialog(
              context, 'Display Name', profile.displayName,
              (v) => notifier.updateProfile(displayName: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Email',
            value: profile.email.isNotEmpty ? profile.email : '—',
            icon: Icons.email_outlined,
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Date of Birth',
            value: profile.dateOfBirth ?? '—',
            icon: Icons.cake_outlined,
            onTap: () => _showDatePicker(context, (d) {
              if (d != null) notifier.updateProfile(dateOfBirth: d);
            }),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Gender',
            value: profile.gender ?? '—',
            icon: Icons.wc_outlined,
            onTap: () => _showPicker(context, 'Gender',
              ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
              profile.gender,
              (v) => notifier.updateProfile(gender: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Height',
            value: profile.heightCm != null ? '${profile.heightCm!.toStringAsFixed(0)} cm' : '—',
            icon: Icons.straighten_outlined,
            onTap: () => _showNumberDialog(
              context, 'Height (cm)', profile.heightCm,
              (v) => notifier.updateProfile(heightCm: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Weight',
            value: profile.weightKg != null ? '${profile.weightKg!.toStringAsFixed(0)} kg' : '—',
            icon: Icons.monitor_weight_outlined,
            onTap: () => _showNumberDialog(
              context, 'Weight (kg)', profile.weightKg,
              (v) => notifier.updateProfile(weightKg: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Activity Level',
            value: profile.activityLevel ?? '—',
            icon: Icons.directions_run_outlined,
            onTap: () => _showPicker(context, 'Activity Level',
              ['Sedentary', 'Lightly active', 'Moderately active', 'Very active', 'Extra active'],
              profile.activityLevel,
              (v) => notifier.updateProfile(activityLevel: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Country',
            value: profile.countryCode,
            icon: Icons.public,
            onTap: () => _showPicker(context, 'Country Code',
              ['US', 'FR', 'GB', 'DE', 'JP', 'IN', 'CM', 'CN', 'MX', 'IT'],
              profile.countryCode,
              (v) => notifier.updateProfile(countryCode: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Currency',
            value: profile.currencyCode,
            icon: Icons.attach_money_outlined,
            onTap: () => _showPicker(context, 'Currency Code',
              ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'XAF', 'CNY', 'MXN'],
              profile.currencyCode,
              (v) => notifier.updateProfile(currencyCode: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Cooking Skill',
            value: profile.cookingSkill ?? '—',
            icon: Icons.kitchen_outlined,
            onTap: () => _showPicker(context, 'Cooking Skill',
              ['BEGINNER', 'BALANCED', 'BATCH COOK', 'CHEF MODE'],
              profile.cookingSkill,
              (v) => notifier.updateProfile(cookingSkill: v),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Household Size',
            value: profile.householdSize != null ? '${profile.householdSize}' : '—',
            icon: Icons.people_outline,
            onTap: () => _showNumberDialog(
              context, 'Household Size', profile.householdSize?.toDouble(),
              (v) => notifier.updateProfile(householdSize: v?.toInt()),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ProfileEditableRow(
            label: 'Health Goals',
            value: profile.healthGoals?.isNotEmpty == true ? profile.healthGoals! : '—',
            icon: Icons.flag_outlined,
            onTap: () => _showEditDialog(
              context, 'Health Goals', profile.healthGoals ?? '',
              (v) => notifier.updateProfile(healthGoals: v),
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialogue de saisie textuelle.
  void _showEditDialog(
    BuildContext context,
    String field,
    String current,
    ValueChanged<String> onSave,
  ) {
    final controller = TextEditingController(text: current);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialogue de saisie numérique.
  void _showNumberDialog(
    BuildContext context,
    String field,
    double? current,
    ValueChanged<double?> onSave,
  ) {
    final controller = TextEditingController(
      text: current?.toStringAsFixed(0) ?? '',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter $field'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              onSave(value);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Affiche un sélecteur de date.
  void _showDatePicker(BuildContext context, ValueChanged<String?> onSave) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
    ).then((date) {
      if (date != null) {
        onSave(date.toIso8601String().split('T').first);
      }
    });
  }

  /// Affiche un sélecteur par liste d'options.
  void _showPicker(
    BuildContext context,
    String title,
    List<String> options,
    String? current,
    ValueChanged<String> onSave,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: options.map((opt) => RadioListTile<String>(
          title: Text(opt),
          value: opt,
          groupValue: current,
          onChanged: (v) {
            if (v != null) {
              onSave(v);
              Navigator.pop(ctx);
            }
          },
        )).toList(),
      ),
    );
  }
}
