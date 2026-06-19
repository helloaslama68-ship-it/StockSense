import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../models/inventory_loss.dart';
import '../../providers/loss_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_confirm_dialog.dart';
import 'log_loss_screen.dart';

class LossDetailScreen extends StatelessWidget {
  final InventoryLoss loss;
  const LossDetailScreen({super.key, required this.loss});

  static const _meta = {
    'damaged': (label: 'Damaged', color: AppColors.darkBlue2,    bg: AppColors.lightBlue),
    'spoiled': (label: 'Spoiled', color: AppColors.forestGreen,  bg: AppColors.lightGreen),
    'expired': (label: 'Expired', color: AppColors.darkRed,      bg: AppColors.lightRed),
    'other':   (label: 'Other',   color: AppColors.charcoalGrey, bg: AppColors.creamBg),
  };

  IconData _reasonIcon(String reason) {
    switch (reason) {
      case 'damaged': return Icons.broken_image_rounded;
      case 'spoiled': return Icons.warning_amber_rounded;
      case 'expired': return Icons.hourglass_disabled_rounded;
      default:        return Icons.delete_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = _meta[loss.reason] ?? _meta['other']!;
    final cs = Theme.of(context).colorScheme;

    // dark-mode badge colors
    final badgeBg    = isDark ? m.color.withOpacity(0.18) : m.bg;
    final badgeColor = isDark ? _lighten(m.color) : m.color;

    final marketRate = loss.qty > 0
        ? (loss.valuationLoss / loss.qty).toStringAsFixed(0)
        : '0';

    // Look up product for image
    final product = context.read<ProductProvider>().allProducts
        .cast<dynamic>()
        .firstWhere((p) => p.id == loss.productId, orElse: () => null);
    final imgPath = product?.imagePath as String?;
    final hasImg  = imgPath != null && imgPath.isNotEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Loss Details',
          style: TextStyle(
            color: AppColors.goldDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // PRODUCT HERO CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark2 : AppColors.warmOrange,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImg
                  ? Stack(
                      children: [
                        Image.file(
                          File(imgPath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // gradient overlay so text stays readable
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.transparent,
                                  AppColors.black.withOpacity(0.65),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Text(
                                'SKU: ${loss.productId.length > 8 ? loss.productId.substring(0, 8).toUpperCase() : loss.productId.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loss.productName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.goldDark.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              _reasonIcon(loss.reason),
                              color: AppColors.goldDark,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'SKU: ${loss.productId.length > 8 ? loss.productId.substring(0, 8).toUpperCase() : loss.productId.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loss.productName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // LOSS VALUE + QUANTITY ROW
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _InfoCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL LOSS VALUE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${loss.valuationLoss.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Market Rate: ₹$marketRate/${loss.unit ?? 'unit'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _InfoCard(
                    isDark: isDark,
                    bgColor: isDark ? AppColors.darkGold : AppColors.warmOrange,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUANTITY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Show decimal if needed
                          loss.qty == loss.qty.truncateToDouble()
                              ? loss.qty.toInt().toString()
                              : loss.qty.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            height: 1,
                          ),
                        ),
                        Text(
                          (loss.unit ?? 'UNIT').toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // LOSS TYPE + DATE
            _InfoCard(
              isDark: isDark,
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_rounded,
                    label: 'Loss Type',
                    isDark: isDark,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 20,
                    color: isDark ? AppColors.dividerDark : AppColors.lightGrey,
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date Recorded',
                    isDark: isDark,
                    trailing: Text(
                      formatDate(loss.loggedAt),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // INTERNAL NOTES
            _InfoCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERNAL NOTES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark2
                          : AppColors.warmOrange.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.goldDark.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      'Product ID: ${loss.productId}\nLogged ${m.label.toLowerCase()} — ${loss.qtyDisplay} at ₹$marketRate/${loss.unit ?? 'unit'}.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.mutedGrey : AppColors.charcoalGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Pass existing loss — enters edit mode
                        builder: (_) => LogLossScreen(editLoss: loss),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Entry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(
                        color: isDark ? AppColors.dividerDark : AppColors.lightGrey,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_rounded, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkRed,
                      side: const BorderSide(color: AppColors.darkRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Loss Entry?',
      message: 'Remove "${loss.productName}" from loss log?',
    );
    if (confirmed && context.mounted) {
      await context.read<LossProvider>().deleteLoss(loss.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Color _lighten(Color c) => Color.lerp(c, Colors.white, 0.35)!;
}

// REUSABLE CARD

class _InfoCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? bgColor;
  const _InfoCard({required this.child, required this.isDark, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )],
      ),
      child: child,
    );
  }
}

// DETAIL ROW

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool isDark;
  const _DetailRow({required this.icon, required this.label, required this.trailing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.warmGrey : AppColors.charcoalGrey,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }
}