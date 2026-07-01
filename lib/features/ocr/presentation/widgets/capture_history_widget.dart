import 'package:flutter/material.dart';
import 'package:money_me/app/theme.dart';
import 'package:money_me/shared/widgets/money_empty_state.dart';


class CaptureHistoryItem {
  final int id;
  final String source;
  final String status;
  final String? merchantName;
  final int? totalCents;
  final double? confidenceScore;
  final String? errorMessage;
  final String createdAt;
  final bool canConfirm;

  const CaptureHistoryItem({
    required this.id,
    required this.source,
    required this.status,
    this.merchantName,
    this.totalCents,
    this.confidenceScore,
    this.errorMessage,
    required this.createdAt,
    this.canConfirm = false,
  });

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending review';
      case 'processing': return 'Processing...';
      case 'completed': return 'Completed';
      case 'failed': return 'Failed';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'processing': return AppColors.info;
      case 'completed': return AppColors.success;
      case 'failed': return AppColors.error;
      default: return AppColors.textTertiary;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'processing': return Icons.sync;
      case 'completed': return Icons.check_circle;
      case 'failed': return Icons.error;
      default: return Icons.help;
    }
  }
}

class CaptureHistoryWidget extends StatelessWidget {
  final List<CaptureHistoryItem> items;
  final void Function(CaptureHistoryItem)? onTap;
  final VoidCallback? onManualEntry;

  const CaptureHistoryWidget({
    super.key,
    required this.items,
    this.onTap,
    this.onManualEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoneyEmptyState(
              icon: Icons.history,
              title: 'No scans yet',
              message: 'Your receipt and invoice scans will appear here',
              action: onManualEntry != null
                  ? TextButton(onPressed: onManualEntry, child: const Text('Enter Manually'))
                  : null,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Scans', style: AppTypography.titleLarge),
                if (onManualEntry != null)
                  TextButton.icon(
                    onPressed: onManualEntry,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manual'),
                  ),
              ],
            ),
          );
        }
        final item = items[index - 1];
        return _buildHistoryCard(context, item);
      },
    );
  }

  Widget _buildHistoryCard(BuildContext context, CaptureHistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => onTap?.call(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.statusIcon, color: item.statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.merchantName ?? 'Unknown merchant',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: TextStyle(fontSize: 10, color: item.statusColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.createdAt,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.totalCents != null)
                Text(
                  'S/ ${(item.totalCents! / 100).toStringAsFixed(2)}',
                  style: AppTypography.amountSmall,
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
