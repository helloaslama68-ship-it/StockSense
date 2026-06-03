import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/app_snack_bar.dart';

enum CreditStatus { highDue, noDue, pending }

class Customer {
  final String id;
  final String name;
  final String phone;
  final double amountDue;
  final CreditStatus status;

  Customer({required this.id, required this.name, required this.phone, required this.amountDue, required this.status});
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchCtrl = TextEditingController();

  final List<Customer> _customers = [
    Customer(id: '1', name: 'Alexander',    phone: '+91 98765 43210', amountDue: 1240.50, status: CreditStatus.highDue),
    Customer(id: '2', name: 'Elena',        phone: '+91 91234 56789', amountDue: 0.00,    status: CreditStatus.noDue),
    Customer(id: '3', name: 'Arjun',        phone: '+91 88776 65544', amountDue: 450.00,  status: CreditStatus.pending),
    Customer(id: '4', name: 'Sarah',        phone: '+91 77665 44332', amountDue: 3499.00, status: CreditStatus.highDue),
    Customer(id: '5', name: 'Vikram Singh', phone: '+91 99001 12233', amountDue: 0.00,    status: CreditStatus.noDue),
    Customer(id: '6', name: 'Meera',        phone: '+91 81818 27272', amountDue: 125.75,  status: CreditStatus.pending),
  ];

  List<Customer> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers.where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q)).toList();
  }

  double get _totalDue => _customers.fold(0, (s, c) => s + c.amountDue);

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundTop,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: AppColors.black, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Customers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  children: [
                    // SEARCH 
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search customers...',
                          hintStyle: TextStyle(color: AppColors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // STATS
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL ACTIVE', style: TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.grey, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('${_customers.length}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.black)),
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
                                Text('TOTAL DUE', style: const TextStyle(fontSize: 9, letterSpacing: 1, color: AppColors.darkRed, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('₹${_totalDue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkRed)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // LIST 
                    if (_filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline_rounded, size: 48, color: AppColors.lightGrey),
                            const SizedBox(height: 12),
                            Text('No customers found', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.black)),
                          ],
                        ),
                      )
                    else
                      ..._filtered.map((c) => _customerTile(c)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.goldDark,
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _customerTile(Customer c) {
    final color = _statusColor(c.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 12, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text(c.phone, style: TextStyle(fontSize: 12, color: AppColors.grey)),
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
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(_statusLabel(c.status),
                    style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${c.amountDue.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                    color: c.amountDue == 0 ? AppColors.darkGreen : color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl   = TextEditingController();
    final phoneCtrl  = TextEditingController();
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              const Text('Add Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _sheetField('Customer Name', 'e.g. John Doe', nameCtrl),
              _sheetField('Phone Number', '+91 00000 00000', phoneCtrl, isNumber: true),
              _sheetField('Credit Amount (₹)', '0.00', amountCtrl, isNumber: true),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.pop(context);
                    AppSnackBar.success(context, 'Customer added!');
                  },
                  child: const Text('Add Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.goldDark, width: 1.5)),
        ),
      ),
    );
  }
}