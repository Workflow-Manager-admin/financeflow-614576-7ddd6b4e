import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/colors.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/savings_provider.dart';
import '../widgets/savings_suggestion_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_list_item.dart';
import '../services/ads_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AdsService _adsService = AdsService();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isPremium) {
      _adsService.initialize();
      _adsService.loadBannerAd();
    }
  }

  @override
  void dispose() {
    _adsService.disposeBannerAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, UserProvider, SavingsProvider>(
      builder: (context, transactionProvider, userProvider, savingsProvider, _) {
        if (transactionProvider.loadingState == TransactionLoadingState.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (transactionProvider.loadingState == TransactionLoadingState.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transactionProvider.errorMessage ?? 'Unknown error occurred',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      transactionProvider.loadTransactions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final recentTransactions = transactionProvider.transactions.take(5).toList();
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: Icon(userProvider.isPremium ? Icons.workspace_premium : Icons.workspace_premium_outlined),
                onPressed: () => userProvider.togglePremium(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Balance',
                          amount: '\$${transactionProvider.balance.toStringAsFixed(2)}',
                          icon: MdiIcons.walletOutline,
                          iconColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Income',
                          amount: '\$${transactionProvider.totalIncome.toStringAsFixed(2)}',
                          icon: MdiIcons.arrowBottomLeft,
                          iconColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SummaryCard(
                          title: 'Expenses',
                          amount: '\$${transactionProvider.totalExpenses.toStringAsFixed(2)}',
                          icon: MdiIcons.arrowTopRight,
                          iconColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Spending by Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PieChart(
                      PieChartData(
                        sections: _createPieChartSections(transactionProvider),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Savings Suggestions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => savingsProvider.refreshSuggestions(),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: savingsProvider.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = savingsProvider.suggestions[index];
                    return SavingsSuggestionCard(
                      suggestion: suggestion,
                      onImplement: suggestion.isImplemented
                          ? null
                          : () => savingsProvider.markSuggestionImplemented(
                                suggestion.id,
                              ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    return TransactionListItem(
                      transaction: recentTransactions[index],
                      onTap: () {
                        // TODO: Navigate to transaction details
                      },
                    );
                  },
                ),
                if (!userProvider.isPremium && _adsService.isAdLoaded)
                  Container(
                    alignment: Alignment.center,
                    width: _adsService.bannerAd?.size.width.toDouble(),
                    height: _adsService.bannerAd?.size.height.toDouble(),
                    child: AdWidget(ad: _adsService.bannerAd!),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Navigate to add transaction screen
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _createPieChartSections(TransactionProvider provider) {
    final spendingByCategory = provider.getSpendingByCategory();
    final totalExpenses = provider.totalExpenses;

    if (totalExpenses == 0) {
      return [
        PieChartSectionData(
          color: AppColors.divider,
          value: 100,
          title: 'No Data',
          radius: 50,
          titleStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ];
    }

    return spendingByCategory.map((category) {
      final percentage = (category['amount'] as double) / totalExpenses * 100;
      return PieChartSectionData(
        color: _getCategoryColor(category['category'] as String),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    // Generate consistent colors for categories
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.error,
      AppColors.success,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    
    return colors[category.hashCode % colors.length];
  }
}
