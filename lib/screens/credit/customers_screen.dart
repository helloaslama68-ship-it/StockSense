import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../providers/customer_provider.dart';
import '../../models/customer.dart';
import 'add_customer_screen.dart';
import '../../widgets/app_snack_bar.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();

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
                  Text('Customers',
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    const _SearchBar(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: appCardDecoration(radius: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL ACTIVE',
                                    style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 1,
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('${cp.customers.length}',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.darkRed.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL DUE',
                                    style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 1,
                                        color: AppColors.darkRed,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('₹${cp.totalDue.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkRed)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _CustomerList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
        ),
        backgroundColor: AppColors.goldDark,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: appCardDecoration(radius: 12),
      child: TextField(
        controller: _ctrl,
        onChanged: (v) => context.read<CustomerProvider>().setQuery(v),
        decoration: InputDecoration(
          hintText: 'Search customers...',
          hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _CustomerList extends StatelessWidget {
  const _CustomerList();

  @override
  Widget build(BuildContext context) {
    final filtered = context.watch<CustomerProvider>().filtered;
    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No customers found',
        subtitle: 'Tap + to add your first customer',
      );
    }
    return Column(children: filtered.map((c) => _CustomerTile(c)).toList());
  }
}

class _CustomerTile extends StatelessWidget {
  final Customer c;
  const _CustomerTile(this.c);

  Color _statusColor(CreditStatus s) {
    switch (s) {
      case CreditStatus.highDue: return AppColors.darkRed;
      case CreditStatus.noDue:   return AppColors.darkGreen;
      case CreditStatus.pending: return AppColors.goldDark;
    }
  }

  String _statusLabel(CreditStatus s) {
    switch (s) {
      case CreditStatus.highDue: return 'HIGH DUE';
      case CreditStatus.noDue:   return 'NO DUE';
      case CreditStatus.pending: return 'PENDING';
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Customer',
      message: 'Remove ${c.name}?',
    );
    if (confirmed && context.mounted) {
      await context.read<CustomerProvider>().remove(c.id);
      AppSnackBar.success(context, '${c.name} deleted.');
    }
  }

  @override
Widget build(BuildContext context) {
  final color = _statusColor(c.status);
  final balance = context.watch<CustomerProvider>().computeBalance(c.id, c.amountDue);

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customer: c),
      ),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: appCardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(c.phone,
                        style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(_statusLabel(c.status),
                    style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${balance.toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: balance == 0 ? AppColors.darkGreen : color),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCustomerScreen(existing: c),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.goldDark.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.edit_rounded,
                          size: 14, color: AppColors.goldDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppColors.darkRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.delete_rounded,
                          size: 14, color: AppColors.darkRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}