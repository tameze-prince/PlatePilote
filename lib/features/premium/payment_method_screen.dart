import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/spacing.dart';
import '../../core/widgets/primary_button.dart';
import '../../shared/widgets/plate_scaffold.dart';
import 'subscription_provider.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlateScaffold(
      title: 'Payment Method',
      showBack: true,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _cardController,
              decoration: const InputDecoration(
                labelText: 'Card label',
                hintText: 'Visa ending 4242',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save Payment Method',
              icon: Icons.check,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                ref
                    .read(subscriptionProvider.notifier)
                    .setPaymentMethod(_cardController.text);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
