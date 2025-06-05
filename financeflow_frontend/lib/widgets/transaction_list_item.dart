import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../core/theme/colors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? AppColors.success.withAlpha(51)  // 0.2 * 255 ≈ 51
              : AppColors.error.withAlpha(51),
          child: Icon(
            transaction.type == TransactionType.income
                ? MdiIcons.arrowBottomLeft
                : MdiIcons.arrowTopRight,
            color: transaction.type == TransactionType.income
                ? AppColors.success
                : AppColors.error,
          ),
        ),
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.formattedDate,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (transaction.recurrence != RecurrenceType.none)
              Row(
                children: [
                  Icon(
                    MdiIcons.refresh,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    transaction.recurrence.toString().split('.').last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              transaction.formattedAmount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: transaction.type == TransactionType.income
                        ? AppColors.success
                        : AppColors.error,
                  ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: AppColors.error,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
