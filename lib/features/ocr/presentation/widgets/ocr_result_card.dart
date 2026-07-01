import 'package:flutter/material.dart';
import 'package:money_me/features/ocr/domain/entities/ocr_result.dart';

class OcrResultCard extends StatelessWidget {
  final OcrResult result;

  const OcrResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const Divider(),
            if (result.merchant != null) _buildField('Merchant', result.merchant!),
            if (result.amount != null) _buildField('Amount', '\$${result.amount!.toStringAsFixed(2)}'),
            if (result.concept != null) _buildField('Concept', result.concept!),
            const SizedBox(height: 8),
            _buildConfidenceBar(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          result.isHighConfidence ? Icons.check_circle : Icons.warning_amber,
          color: result.isHighConfidence ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          result.isDuplicate ? 'Duplicate Detected' : 'Scan Complete',
          style: theme.textTheme.titleMedium,
        ),
        const Spacer(),
        Text(
          '${result.ocrConfidence.toStringAsFixed(0)}%',
          style: theme.textTheme.titleSmall?.copyWith(
            color: result.isHighConfidence ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confidence', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: result.ocrConfidence / 100,
            backgroundColor: Colors.grey[300],
            color: result.isHighConfidence ? Colors.green : Colors.orange,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
