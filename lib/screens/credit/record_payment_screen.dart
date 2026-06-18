import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../models/credit_transaction.dart';
import '../../providers/record_payment_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/app_snack_bar.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';

class RecordPaymentScreen extends StatelessWidget {
  final Customer customer;
  final TransactionType type;
  final CreditTransaction? existing;

  const RecordPaymentScreen({
    super.key,
    required this.customer,
    this.type = TransactionType.payment,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordPaymentProvider(type: type, existing: existing),
      child: _RecordPaymentView(customer: customer),
    );
  }
}

class _RecordPaymentView extends StatelessWidget {
  final Customer customer;
  const _RecordPaymentView({required this.customer});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecordPaymentProvider>();
    final isPayment = p.type == TransactionType.payment;
    final balance = context
        .watch<CustomerProvider>()
        .computeBalance(customer.id, customer.amountDue);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 14),
                  Text(
                    p.isEdit
                        ? (isPayment ? 'Edit Payment' : 'Edit Credit')
                        : (isPayment ? 'Record Payment' : 'Add Credit'),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRANSACTION MODE',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warmGrey)),
                    const SizedBox(height: 6),
                    Text(isPayment ? 'Payment Received' : 'Credit Entry',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 24),
                    const _FieldLabel('AMOUNT'),
                    const SizedBox(height: 6),
                    AppInputField(
                      controller:
                          context.read<RecordPaymentProvider>().amountCtrl,
                      hint: '0.00',
                      keyboard:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefix: Text('₹',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface)),
                      onChanged: isPayment
                          ? (_) => context
                              .read<RecordPaymentProvider>()
                              .validateAmount(balance)
                          : null,
                    ),
                    if (p.amountError != null) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.warning_rounded,
                            size: 13, color: AppColors.darkRed),
                        const SizedBox(width: 4),
                        Text(
                          p.amountError!,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkRed,
                              fontWeight: FontWeight.w600),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 16),
                    const _FieldLabel('DATE'),
                    const SizedBox(height: 6),
                    const _DatePickerField(),
                    const SizedBox(height: 16),
                    const _FieldLabel('NOTES'),
                    const SizedBox(height: 6),
                    AppInputField(
                      controller:
                          context.read<RecordPaymentProvider>().notesCtrl,
                      hint: 'Add details about this entry...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ENTRY FOR',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 0.8,
                                      color: AppColors.warmGrey,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(customer.name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('BALANCE',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 0.8,
                                      color: AppColors.warmGrey,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkRed),
                              ),
                            ],
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
      bottomNavigationBar: _SaveBar(customer: customer),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.warmGrey,
            letterSpacing: 0.8));
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecordPaymentProvider>();
    final label = formatDate(p.date);

    return GestureDetector(
      onTap: () async {
        final picked = await appShowDatePicker(
          context,
          initialDate: p.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) p.setDate(picked);
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
  final Customer customer;
  const _SaveBar({required this.customer});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RecordPaymentProvider>();

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
        label: p.isEdit ? 'Update Transaction' : 'Save Transaction',
        icon: Icons.check_rounded,
        loading: p.loading,
        onPressed: () async {
          final t = await p.submit(customer.id);
          if (!context.mounted) return;
          if (t != null) {
            AppSnackBar.success(
              context,
              p.isEdit ? 'Transaction updated!' : 'Transaction saved!',
            );
            Navigator.pop(context, t);
          } else {
            AppSnackBar.error(
                context, p.amountError ?? 'Enter a valid amount.');
          }
        },
      ),
    );
  }
}