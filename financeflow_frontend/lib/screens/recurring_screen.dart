import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';

import '../providers/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Payments'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final recurringTransactions = provider.recurringTransactions;

          if (recurringTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring payments yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a transaction and mark it as recurring',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: recurringTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recurringTransactions[index];
              return TransactionListItem(
                transaction: transaction,
                onTap: () {
                  // TODO: Navigate to transaction details
                },
                onDelete: () async {
                  if (!context.mounted) return;
                  
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Delete Recurring Payment'),
                      content: const Text(
                        'Are you sure you want to delete this recurring payment?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    Provider.of<TransactionProvider>(context, listen: false)
                        .removeTransaction(transaction.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
