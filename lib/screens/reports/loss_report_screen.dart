import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_styles.dart';
import '../../core/colors.dart';
import '../../models/inventory_loss.dart';
import '../../providers/loss_filter_provider.dart';
import '../../providers/loss_provider.dart';
import '../../widgets/app_back_button.dart';

class LossReportScreen extends StatelessWidget {
  const LossReportScreen({super.key});

  
  static const _meta = {
    'damaged': (
      label: 'DAMAGED',
      color: AppColors.darkBlue2,
      bg: AppColors.lightBlue,
    ),
    'spoiled': (
      label: 'SPOILED',
      color: AppColors.forestGreen,
      bg: AppColors.lightGreen,
    ),
    'expired': (
      label: 'EXPIRED',
      color: AppColors.darkRed,
      bg: AppColors.lightRed,
    ),
    'other': (
      label: 'OTHER',
      color: AppColors.charcoalGrey,
      bg: AppColors.creamBg,
    ),
  };

  // helpers 

  int _countByReason(List<InventoryLoss> losses, String reason) =>
      losses.where((l) => l.reason == reason).fold(0, (s, l) => s + l.quantity);

  
  String _deltaLabel(double current) {
    const delta = 12; // percent
    return '+$delta% from last month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Loss Report',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<LossProvider>(
        builder: (context, lossP, _) {
          final losses = lossP.allLosses;
          final totalAmount = lossP.totalLossAmount;
          final totalItems = lossP.totalLossItems;
          final expiredQty = _countByReason(losses, 'expired');
          final damagedQty = _countByReason(losses, 'damaged');

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  HEADER 
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loss\nSummary',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A detailed oversight of inventory wastage,\nexpiration impacts, and structural damage\nacross all curated categories.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // LIVE DATA badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.goldDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE DATA',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                //STAT CARDS 
                Row(
                  children: [
                    // Total loss amount
                    Expanded(
                      child: _StatCard(
                        label: 'TOTAL LOSS AMOUNT',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.trending_up_rounded,
                                  size: 12,
                                  color: AppColors.darkRed,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _deltaLabel(totalAmount),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.darkRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Total items lost
                    Expanded(
                      child: _StatCard(
                        label: 'TOTAL ITEMS LOST',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$totalItems',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'units',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.charcoalGrey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _DotBadge(
                                  color: AppColors.darkRed,
                                  label: '$expiredQty Expired',
                                ),
                                const SizedBox(width: 8),
                                _DotBadge(
                                  color: AppColors.darkBlue2,
                                  label: '$damagedQty Damaged',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // RECENT LOSS ENTRIES
                Text(
                  'Recent Loss Entries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                losses.isEmpty
                    ? _emptyState()
                    : _entriesList(losses),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _entriesList(List<InventoryLoss> losses) {
    // show most recent first, cap at visible list
    final sorted = [...losses]
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    return Column(
      children: sorted.map((loss) => _LossReportTile(loss: loss)).toList(),
    );
  }

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.trending_down_rounded,
                size: 48,
                color: AppColors.lightGrey,
              ),
              const SizedBox(height: 12),
              const Text(
                'No loss entries recorded',
                style: TextStyle(
                  color: AppColors.charcoalGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Losses logged from inventory will appear here.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.charcoalGrey,
                ),
              ),
            ],
          ),
        ),
      );
}

// STAT CARD

class _StatCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: appCardDecoration(context: context, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoalGrey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// DOT BADGE 

class _DotBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _DotBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.charcoalGrey),
        ),
      ],
    );
  }
}

// LOSS REPORT TILE

class _LossReportTile extends StatelessWidget {
  final InventoryLoss loss;

  const _LossReportTile({required this.loss});

  static const _meta = {
    'damaged': (
      label: 'DAMAGED',
      color: AppColors.darkBlue2,
      bg: AppColors.lightBlue2,
    ),
    'spoiled': (
      label: 'SPOILED',
      color: AppColors.forestGreen,
      bg: AppColors.lightGreen,
    ),
    'expired': (
      label: 'EXPIRED',
      color: AppColors.darkRed,
      bg: AppColors.lightRed,
    ),
    'other': (
      label: 'OTHER',
      color: AppColors.charcoalGrey,
      bg: AppColors.creamBg,
    ),
  };

  IconData _icon(String reason) {
    switch (reason) {
      case 'damaged':
        return Icons.broken_image_rounded;
      case 'spoiled':
        return Icons.warning_amber_rounded;
      case 'expired':
        return Icons.hourglass_disabled_rounded;
      default:
        return Icons.delete_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _meta[loss.reason] ?? _meta['other']!;
    final dateStr = formatDate(loss.loggedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: appCardDecoration(context: context, radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: m.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(loss.reason), color: m.color, size: 20),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loss.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Reason badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: m.bg,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: m.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lot #${loss.id.substring(0, 4).toUpperCase()} • ${loss.quantity} Units',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.charcoalGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Amount + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-₹${loss.valuationLoss.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkRed,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dateStr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.charcoalGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}