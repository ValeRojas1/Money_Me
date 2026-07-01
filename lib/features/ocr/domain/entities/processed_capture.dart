enum CaptureStatus { pending, processing, completed, failed }
enum CaptureSource { receipt, invoice, bankStatement, manual }

class ProcessedCapture {
  final int id;
  final int userId;
  final CaptureSource source;
  final CaptureStatus status;
  final String? rawImageUrl;
  final String? processedImageUrl;
  final String? rawText;
  final String? merchantName;
  final int? totalCents;
  final String? currency;
  final DateTime? captureDate;
  final double? confidenceScore;
  final String? errorMessage;
  final String? detectedItems;
  final DateTime createdAt;
  final DateTime? processedAt;

  const ProcessedCapture({
    required this.id,
    required this.userId,
    required this.source,
    this.status = CaptureStatus.pending,
    this.rawImageUrl,
    this.processedImageUrl,
    this.rawText,
    this.merchantName,
    this.totalCents,
    this.currency,
    this.captureDate,
    this.confidenceScore,
    this.errorMessage,
    this.detectedItems,
    required this.createdAt,
    this.processedAt,
  });
}
