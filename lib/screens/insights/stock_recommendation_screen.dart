import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/app_styles.dart';
import '../../widgets/app_back_button.dart';
import '../../models/product.dart';
import '../../providers/stock_recommendation_provider.dart';
import '../purchase/purchase_screen.dart';
import '../../widgets/empty_state.dart';


// STOCK RECOMMENDATION SCREEN 
// suggestions ignore StockRecommendationProvider

class StockRecommendationScreen extends StatelessWidget {
  const StockRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockRecommendationProvider>();
    final visible  = provider.visible;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(child: AppBackButton()),
        ),
        title: Row(children: [
          const Icon(Icons.bolt_rounded, color: AppColors.goldDark, size: 16),
          const SizedBox(width: 4),
          const Text('Suggestion',
              style: TextStyle(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Restock Suggestions',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Smart AI insights based on your recent sales velocity.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.check_circle_rounded,
                    title: 'All stocked up!',
                    subtitle: 'No restock suggestions right now',
                    iconColor: AppColors.darkGreen,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _SuggestionCard(
                      suggestion: visible[i],
                      onAddToPurchase: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PurchaseScreen(
                            preselectedProduct: visible[i].product,
                          ),
                        ),
                      ),
                      
                      onIgnore: () =>
                          context.read<StockRecommendationProvider>()
                              .ignore(visible[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


//  SUGGESTION CARD

class _SuggestionCard extends StatelessWidget {
  final Suggestion   suggestion;
  final VoidCallback onAddToPurchase;
  final VoidCallback onIgnore;

  const _SuggestionCard({
    required this.suggestion,
    required this.onAddToPurchase,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final p        = suggestion.product;
    final hasImage = p.imagePath != null && p.imagePath!.isNotEmpty;

    return Container(
      decoration: appCardDecoration(),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(p.imagePath!), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.inventory_2_rounded,
                        color: AppColors.grey, size: 28),
              ),
              const SizedBox(width: 12),

              // Name + units
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${p.quantity} CURRENT UNITS',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),

              Text('${p.quantity}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Reason
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.goldDark.withOpacity(0.07),
            border: Border(
              top: BorderSide(
                  color: AppColors.goldDark.withOpacity(0.15), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.goldDark, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(suggestion.reason,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.black.withOpacity(0.75),
                        height: 1.4)),
              ),
            ],
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: onAddToPurchase,
                  child: const Text('Add to Purchase List',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 42,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.lightGrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: onIgnore,
                child: Text('Ignore',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}