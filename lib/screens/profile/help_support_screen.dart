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
  String _searchQuery = '';

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

  List<_FaqItem> get _filtered {
    if (_searchQuery.isEmpty) return _faqs;
    final q = _searchQuery.toLowerCase();
    return _faqs
        .where((f) =>
            f.question.toLowerCase().contains(q) ||
            f.answer.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = isDark ? Colors.white : AppColors.black;
    final textSecondary = isDark ? const Color(0xFF9E9E9E) : AppColors.grey;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
                  color: isDark ? Colors.white12 : AppColors.lightGrey,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search help topics...',
                  hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  if (_filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'No results for "$_searchQuery"',
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
                          color:
                              isDark ? Colors.white12 : AppColors.lightGrey,
                        ),
                      ),
                      child: Column(
                        children: _filtered.asMap().entries.map((entry) {
                          final i = entry.key;
                          final item = entry.value;
                          final isLast = i == _filtered.length - 1;
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
                                  color: isDark
                                      ? Colors.white12
                                      : AppColors.lightGrey,
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
                          style: TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
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
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  final Color textPrimary;
  final Color textSecondary;

  const _FaqTile({
    required this.item,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
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
                    widget.item.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: widget.textSecondary,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(
                widget.item.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
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