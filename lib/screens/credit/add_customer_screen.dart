import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../providers/customer_form_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_section_label.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../models/customer.dart';
import 'customers_screen.dart';

class AddCustomerScreen extends StatelessWidget {
  final Customer? existing;
  const AddCustomerScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerFormProvider(existing: existing),
      child: _AddCustomerView(
        isEdit: existing != null,
        existingId: existing?.id,
      ),
    );
  }
}

class _AddCustomerView extends StatelessWidget {
  final bool isEdit;
  final String? existingId;
  const _AddCustomerView({this.isEdit = false, this.existingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  Text(isEdit ? 'Edit Customer' : 'Add Customer',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionLabel(label: 'CUSTOMER DETAILS'),
                          const SizedBox(height: 14),
                          const _FieldLabel('CUSTOMER NAME'),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: context.read<CustomerFormProvider>().nameCtrl,
                            hint: 'John Doe',
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('PHONE NUMBER'),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: context.read<CustomerFormProvider>().phoneCtrl,
                            hint: '00000 00000',
                            keyboard: TextInputType.phone,
                            prefix: Text('+91',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('ADDRESS', optional: true),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: context.read<CustomerFormProvider>().addressCtrl,
                            hint: 'Shop address or location details...',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.goldDark.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.account_balance_wallet_rounded,
                                    color: AppColors.goldDark, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Initial Credit',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _FieldLabel('EDIT AMOUNT'),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: context.read<CustomerFormProvider>().amountCtrl,
                            hint: '0.00',
                            keyboard: const TextInputType.numberWithOptions(decimal: true),
                            prefix: Text('₹',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface)),
                          ),
                          const SizedBox(height: 6),
                          Text('Enter amount if customer has pending payment',
                              style: TextStyle(fontSize: 11, color: AppColors.warmGrey)),
                          const SizedBox(height: 14),
                          const _FieldLabel('DATE'),
                          const SizedBox(height: 6),
                          const _DatePickerField(),
                          const SizedBox(height: 14),
                          const _FieldLabel('NOTES', optional: true),
                          const SizedBox(height: 6),
                          AppInputField(
                            controller: context.read<CustomerFormProvider>().notesCtrl,
                            hint: 'e.g. Previous shop balance',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(isEdit: isEdit, existingId: existingId),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool optional;
  const _FieldLabel(this.text, {this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.warmGrey,
                letterSpacing: 0.8)),
        if (optional) ...[
          const SizedBox(width: 6),
          const Text('OPTIONAL',
              style: TextStyle(
                  fontSize: 9, color: AppColors.warmGrey, letterSpacing: 0.5)),
        ],
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerFormProvider>();
    final label =
        '${p.creditDate.month}/${p.creditDate.day}/${p.creditDate.year}';

    return GestureDetector(
      onTap: () async {
        final picked = await appShowDatePicker(
          context,
          initialDate: p.creditDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) p.setCreditDate(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.goldDark),
          ],
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool isEdit;
  final String? existingId;
  const _SaveBar({this.isEdit = false, this.existingId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CustomerFormProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: GoldButton(
        label: isEdit ? 'Update Customer' : 'Save Customer',
        icon: Icons.arrow_forward_rounded,
        loading: p.loading,
        onPressed: () async {
          final ok = await p.submit();
          if (!context.mounted) return;
          if (ok) {
            final customer = Customer.create(
              id: isEdit
                  ? existingId!
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              name: p.nameCtrl.text.trim(),
              phone: '+91 ${p.phoneCtrl.text.trim()}',
              amountDue: double.tryParse(p.amountCtrl.text) ?? 0.0,
              status: (double.tryParse(p.amountCtrl.text) ?? 0) > 0
                  ? CreditStatus.pending
                  : CreditStatus.noDue,
            );
            if (isEdit) {
              await context.read<CustomerProvider>().update(customer);
            } else {
              await context.read<CustomerProvider>().add(customer);
            }
            AppSnackBar.success(
                context, isEdit ? 'Customer updated!' : 'Customer added!');
            Navigator.pop(context);
          } else {
            AppSnackBar.error(context, 'Please enter customer name.');
          }
        },
      ),
    );
  }
}