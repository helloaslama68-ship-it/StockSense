import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../widgets/app_back_button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');

  final List<_FaqItem> _faqs = const [
    _FaqItem(
      question: 'How to add a product?',
      answer:
          'Go to Inventory → tap the + button at the bottom right. Fill in product name, category, price, stock quantity, and optionally a barcode or expiry date. Tap Save.',
    ),
    _FaqItem(
      question: 'How to record a sale?',
      answer:
          'Tap Sales from the bottom nav. Tap New Sale, search or scan products to add line items, select a customer if needed, apply tax, then tap Complete Sale.',
    ),
    _FaqItem(
      question: 'How to track expiry items?',
      answer:
          'Products with expiry dates show in Alerts. Go to Alerts screen to see items expiring soon. You can set low stock and expiry alert thresholds in Settings → Notifications.',
    ),
    _FaqItem(
      question: 'How to manage customer credit?',
      answer:
          'Go to Credit tab. Add a customer, then record credit transactions against them. Use Record Payment to mark credit as paid. View full history in Customer Detail.',
    ),
    _FaqItem(
      question: 'How to backup data?',
      answer:
          'Go to Settings → Data & Storage → Backup. You can export your data to a local file or sync to cloud. Restore from the same screen using a previous backup file.',
    ),
  ];

  List<_FaqItem> _filtered(String query) {
    if (query.isEmpty) return _faqs;
    final q = query.toLowerCase();
    return _faqs
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? AppColors.white : AppColors.black;
    final textSecondary = isDark ? AppColors.warmGrey : AppColors.grey;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.white;

    return ValueListenableBuilder<String>(
      valueListenable: _searchQuery,
      builder: (context, query, _) {
        final filtered = _filtered(query);
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Center(child: AppBackButton()),
            ),
            title: Text(
              'Help & Support',
              style: TextStyle(
                color: AppColors.goldDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.white38 : AppColors.lightGrey,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => _searchQuery.value = v,
                    style: TextStyle(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search help topics...',
                      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Common Questions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Center(
                            child: Text(
                              'No results for "$query"',
                              style: TextStyle(color: textSecondary, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.white38 : AppColors.lightGrey,
                            ),
                          ),
                          child: Column(
                            children: filtered.asMap().entries.map((entry) {
                              final i = entry.key;
                              final item = entry.value;
                              final isLast = i == filtered.length - 1;
                              return Column(
                                children: [
                                  _FaqTile(
                                    item: item,
                                    textPrimary: textPrimary,
                                    textSecondary: textSecondary,
                                  ),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      color: isDark ? AppColors.white38 : AppColors.lightGrey,
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'STOCKSENSE V2.4.1',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Handcrafted by StockSense Dev Team',
                              style: TextStyle(fontSize: 11, color: textSecondary),
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
        );
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _FaqItem item;
  final Color textPrimary;
  final Color textSecondary;

  const _FaqTile({
    required this.item,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = ValueNotifier<bool>(false);
    return ValueListenableBuilder<bool>(
      valueListenable: expanded,
      builder: (_, isExpanded, __) => InkWell(
        onTap: () => expanded.value = !expanded.value,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                Text(
                  item.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}